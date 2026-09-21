
-- DATABASE & TABLE CREATION --

CREATE DATABASE IF NOT EXISTS hr_data_analytics;
USE hr_data_analytics;


-- Main table: holds all employee records from the CSV

CREATE TABLE employees (
    EmployeeNumber INT PRIMARY KEY,
    Age INT,
    Attrition VARCHAR(10),
    BusinessTravel VARCHAR(50),
    DailyRate INT,
    Department VARCHAR(50),
    DistanceFromHome INT,
    Education INT,
    EducationField VARCHAR(50),
    EnvironmentSatisfaction INT,
    Gender VARCHAR(10),
    HourlyRate INT,
    JobInvolvement INT,
    JobLevel INT,
    JobRole VARCHAR(50),
    JobSatisfaction INT,
    MaritalStatus VARCHAR(20),
    MonthlyIncome INT,
    MonthlyRate INT,
    NumCompaniesWorked INT,
    OverTime VARCHAR(5),
    PercentSalaryHike INT,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT,
    ManagerID INT
    );


-- Second table: Bsiness Context Data

CREATE TABLE department_budget (
    Department VARCHAR(50) PRIMARY KEY,
    AnnualBudget DECIMAL(12,2),
    HeadCountTarget INT
);


INSERT INTO department_budget (Department, AnnualBudget, HeadCountTarget) VALUES
('Sales', 5000000.00, 450),
('Research & Development', 8000000.00, 900),
('Human Resources', 1000000.00, 100);

