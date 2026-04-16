SELECT COUNT(*) AS total_rows from hr_employee;
SELECT COUNT(*) AS null_employee_ids FROM hr_employee WHERE EmployeeNumber IS NULL;
SELECT Attrition,
COUNT(*) AS total,
ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),2) AS percentage 
FROM hr_employee
GROUP BY Attrition 
ORDER BY total DESC;