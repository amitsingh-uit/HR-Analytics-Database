-- Import all table data from the tables --

Select * from employees;
Select * from department_budget ;

-- Randomly assigning ManagerID -- Used AI to understand the probem through the previous code

-- Step 1: Managers ki list ek temporary table mein nikal lo
CREATE TEMPORARY TABLE temp_managers AS
SELECT EmployeeNumber AS ManagerID FROM employees WHERE JobLevel >= 4;

-- Step 2: Ab employees table ko update karo, temp_managers se random manager assign karke
UPDATE employees e
JOIN (
    SELECT EmployeeNumber,
           (SELECT ManagerID FROM temp_managers ORDER BY RAND() LIMIT 1) AS assigned_manager
    FROM employees
    WHERE JobLevel < 4
) sub ON e.EmployeeNumber = sub.EmployeeNumber
SET e.ManagerID = sub.assigned_manager;

-- Step 3: Temporary table hata do (cleanup)
DROP TEMPORARY TABLE temp_managers;

-- Q1. List all employees who left the company (Attrition = Yes)
SELECT EmployeeNumber, Department, JobRole, MonthlyIncome
FROM employees
WHERE Attrition = 'Yes';
  
-- Q2. List employees earning more than 10,000 monthly, sorted by income
SELECT EmployeeNumber, JobRole, MonthlyIncome
FROM employees
WHERE MonthlyIncome > 10000
ORDER BY MonthlyIncome DESC;
 
-- Q3. Count total employees per Department
SELECT Department, COUNT(*) AS total_employees
FROM employees
GROUP BY Department;

-- Q4. Average monthly income per department
SELECT Department, ROUND(AVG(MonthlyIncome), 2) AS avg_income
FROM employees
GROUP BY Department;
 
-- Q5. Departments where average income is above 6000
SELECT Department, ROUND(AVG(MonthlyIncome), 2) AS avg_income
FROM employees
GROUP BY Department
HAVING AVG(MonthlyIncome) > 6000;
 
-- Q6. Attrition rate (%) per department
SELECT Department,
       COUNT(*) AS total_employees,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM employees
GROUP BY Department
ORDER BY attrition_rate DESC;

-- Q7. Average years at company by job role, only for roles with more than 20 employees
SELECT JobRole, COUNT(*) AS employee_count, ROUND(AVG(YearsAtCompany), 1) AS avg_years
FROM employees
GROUP BY JobRole
HAVING COUNT(*) > 20
ORDER BY avg_years DESC;
 
-- Q8. Gender-wise average salary and headcount
SELECT Gender, COUNT(*) AS total_employee, ROUND(AVG(MonthlyIncome), 2) AS avg_salary
FROM employees
GROUP BY Gender;

-- Q9. Employees earning more than the overall average salary
SELECT EmployeeNumber, JobRole, MonthlyIncome
FROM employees
WHERE MonthlyIncome > (SELECT AVG(MonthlyIncome) FROM employees);
 
-- Q10. Employees earning below their OWN job role's average salary (correlated subquery)
SELECT e1.EmployeeNumber, e1.JobRole, e1.MonthlyIncome
FROM employees e1
WHERE e1.MonthlyIncome < (
    SELECT AVG(e2.MonthlyIncome)
    FROM employees e2
    WHERE e2.JobRole = e1.JobRole
);
 
-- Q11. Departments whose average income is higher than the company-wide average
SELECT Department, ROUND(AVG(MonthlyIncome), 2) AS avg_income
FROM employees
GROUP BY Department
HAVING AVG(MonthlyIncome) > (SELECT AVG(MonthlyIncome) FROM employees);

-- Q12. Employees with their department's annual budget and headcount target
SELECT e.EmployeeNumber, e.Department, e.MonthlyIncome,
       d.AnnualBudget, d.HeadCountTarget
FROM employees e
INNER JOIN department_budget d ON e.Department = d.Department;
 
-- Q13. Department-wise actual headcount vs target headcount, with budget per employee
SELECT e.Department,
       COUNT(e.EmployeeNumber) AS actual_headcount,
       d.HeadCountTarget,
       d.AnnualBudget,
       ROUND(d.AnnualBudget / COUNT(e.EmployeeNumber), 2) AS budget_per_employee
FROM employees e
JOIN department_budget d ON e.Department = d.Department
GROUP BY e.Department, d.HeadCountTarget, d.AnnualBudget;
 
-- Q14. Show all departments even if no employees matched
SELECT d.Department, d.AnnualBudget, COUNT(e.EmployeeNumber) AS employee_count
FROM department_budget d
LEFT JOIN employees e ON d.Department = e.Department
GROUP BY d.Department, d.AnnualBudget;

-- Q15. Show each employee alongside their manager's details (self join)
SELECT emp.EmployeeNumber   AS employee_id,
       emp.JobRole          AS employee_role,
       emp.MonthlyIncome    AS employee_salary,
       mgr.EmployeeNumber   AS manager_id,
       mgr.JobRole          AS manager_role,
       mgr.MonthlyIncome    AS manager_salary
FROM employees emp
JOIN employees mgr ON emp.ManagerID = mgr.EmployeeNumber
LIMIT 20;
 
-- Q16. Count how many direct reports each manager has
SELECT mgr.EmployeeNumber AS manager_id, mgr.JobRole AS manager_role,
       COUNT(emp.EmployeeNumber) AS direct_reports
FROM employees mgr
JOIN employees emp ON emp.ManagerID = mgr.EmployeeNumber
GROUP BY mgr.EmployeeNumber, mgr.JobRole
ORDER BY direct_reports DESC;
 
-- Q17. Employees who earn MORE than their own manager (self join + comparison)
SELECT emp.EmployeeNumber, emp.MonthlyIncome AS employee_salary,
       mgr.EmployeeNumber AS manager_id, mgr.MonthlyIncome AS manager_salary
FROM employees emp
JOIN employees mgr ON emp.ManagerID = mgr.EmployeeNumber
WHERE emp.MonthlyIncome > mgr.MonthlyIncome;

-- Q18. Segment employees into salary bands using a CTE
WITH salary_band AS (
    SELECT EmployeeNumber, JobRole, MonthlyIncome,
        CASE
            WHEN MonthlyIncome < 3000 THEN 'Low'
            WHEN MonthlyIncome BETWEEN 3000 AND 8000 THEN 'Medium'
            ELSE 'High'
        END AS income_band
    FROM employees
)
SELECT income_band, COUNT(*) AS total_employees
FROM salary_band
GROUP BY income_band;
 
-- Q19. CTE + JOIN: departments with above-average attrition, joined with budget info
WITH dept_attrition AS (
    SELECT Department,
           ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
    FROM employees
    GROUP BY Department
)
SELECT da.Department, da.attrition_rate, db.AnnualBudget
FROM dept_attrition da
JOIN department_budget db ON da.Department = db.Department
WHERE da.attrition_rate > (SELECT AVG(attrition_rate) FROM dept_attrition);
 
-- Q20. Multiple CTEs used together
WITH dept_avg AS (
    SELECT Department, AVG(MonthlyIncome) AS avg_income
    FROM employees
    GROUP BY Department
),
high_paying_depts AS (
    SELECT Department FROM dept_avg WHERE avg_income > 6000
)
SELECT e.EmployeeNumber, e.Department, e.MonthlyIncome
FROM employees e
JOIN high_paying_depts h ON e.Department = h.Department
ORDER BY e.MonthlyIncome DESC
LIMIT 20;

-- Q21. Rank employees by salary within each JobRole
SELECT EmployeeNumber, JobRole, MonthlyIncome,
       RANK() OVER (PARTITION BY JobRole ORDER BY MonthlyIncome DESC) AS salary_rank
FROM employees;
 
-- Q22. Top 3 highest-paid employees per JobRole (using the ranked result above)
SELECT * FROM (
    SELECT EmployeeNumber, JobRole, MonthlyIncome,
           ROW_NUMBER() OVER (PARTITION BY JobRole ORDER BY MonthlyIncome DESC) AS rn
    FROM employees
) ranked
WHERE rn <= 3;
 
-- Q23. Running total of employee count ordered by hire tenure (YearsAtCompany)
SELECT EmployeeNumber, YearsAtCompany,
       COUNT(*) OVER (ORDER BY YearsAtCompany) AS running_employee_count
FROM employees;
 
-- Q24. Difference between each employee's salary and the department average (window AVG)
SELECT EmployeeNumber, Department, MonthlyIncome,
       ROUND(AVG(MonthlyIncome) OVER (PARTITION BY Department), 2) AS dept_avg_income,
       ROUND(MonthlyIncome - AVG(MonthlyIncome) OVER (PARTITION BY Department), 2) AS diff_from_avg
FROM employees;
 
-- Q25. DENSE_RANK to handle ties in PerformanceRating within each department
SELECT EmployeeNumber, Department, PerformanceRating,
       DENSE_RANK() OVER (PARTITION BY Department ORDER BY PerformanceRating DESC) AS perf_rank
FROM employees;

-- Q26. View: quick access to employees who left the company
CREATE OR REPLACE VIEW high_attrition_employees AS
SELECT EmployeeNumber, Department, JobRole, MonthlyIncome, Attrition
FROM employees
WHERE Attrition = 'Yes';
 
-- Usage:
SELECT * FROM high_attrition_employees;
 
-- Q27. View: department-level summary 
CREATE OR REPLACE VIEW department_summary AS
SELECT Department,
       COUNT(*) AS total_employees,
       ROUND(AVG(MonthlyIncome), 2) AS avg_income,
       ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM employees
GROUP BY Department;

select * from department_summary;

-- Q28. Procedure: get attrition summary for any department passed in as a parameter
DELIMITER //
CREATE PROCEDURE GetDepartmentAttrition(IN dept_name VARCHAR(50))
BEGIN
    SELECT Department,
           COUNT(*) AS total,
           SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS attrition_count,
           ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
    FROM employees
    WHERE Department = dept_name
    GROUP BY Department;
END //
DELIMITER ;

-- Usage:
CALL GetDepartmentAttrition('Sales');
 
-- Q29. Procedure: give a salary hike (%) to all employees in a job role (demonstrates UPDATE inside a procedure)
DELIMITER //
CREATE PROCEDURE GiveSalaryHike(IN role_name VARCHAR(50), IN hike_percent DECIMAL(5,2))
BEGIN
    UPDATE employees
    SET MonthlyIncome = MonthlyIncome + (MonthlyIncome * hike_percent / 100)
    WHERE JobRole = role_name;
END //
DELIMITER ;
 

-- CALL GiveSalaryHike('Sales Executive', 5.0);
 
-- Q30. Function: returns attrition rate for a given department as a single value
DELIMITER //
CREATE FUNCTION GetAttritionRate(dept_name VARCHAR(50))
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE rate DECIMAL(5,2);
    SELECT ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)
    INTO rate
    FROM employees
    WHERE Department = dept_name;
    RETURN rate;
END //
DELIMITER ;
 
SELECT Department, GetAttritionRate(Department) AS attrition_rate
FROM department_budget;