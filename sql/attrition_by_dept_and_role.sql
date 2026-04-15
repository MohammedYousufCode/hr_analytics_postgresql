-- HR Analytics: Attrition by Department and Job Role
-- Business Questions:
--  1. Which department has the highest attrition rate?
--  2. Which job roles are highest attrition risk?

-- Query 1: Attrition by Department
SELECT Department,
COUNT(*) AS totao_employees,
SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
SUM(CASE WHEN Attrition = 'No' THEN 1 ELSE 0 END) AS employees_stayed,
ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS employees_left_rate FROM hr_employee 
GROUP BY Department
ORDER BY employees_left_rate DESC;

-- Query 2: Attrition by Job Role (HAVING + CASE WHEN risk label)
SELECT JobRole,
COUNT(*) AS total_employees,
SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) 
AS employees_left,
ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) 
AS employees_left_rate,
CASE WHEN ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2)>=20
THEN 'High Risk'
WHEN ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2)>=10 
THEN 'Medium Risk'
ELSE 'Low Risk' END 
AS risk_category 
FROM hr_employee
GROUP BY JobRole
HAVING COUNT(*)>=50
ORDER BY employees_left_rate DESC;
