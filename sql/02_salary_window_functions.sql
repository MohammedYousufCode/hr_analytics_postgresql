-- Query 1: Employee salary vs department average
-- Business Question: How does each employee's salary compare within their dept?
SELECT EmployeeNumber,
Department,
JobRole,
MonthlyIncome,
ROUND(AVG(MonthlyIncome) OVER(PARTITION BY Department),2) AS dept_avg_salary,
MonthlyIncome - ROUND(AVG(MonthlyIncome) OVER(PARTITION BY Department),2) AS diff_from_dept_avg,
CASE 
WHEN MonthlyIncome>AVG(MonthlyIncome) OVER(PARTITION BY Department) THEN 'Above Average'
WHEN MonthlyIncome<AVG(MonthlyIncome) OVER(PARTITION BY Department) THEN 'Below Average'
ELSE 'At Average' END AS salary_position
FROM hr_employee
ORDER BY Department,MonthlyIncome DESC;

-- Query 2: Top 3 earners per department using RANK()
-- Business Question: Who are the highest paid employees in each department?
WITH ranked_salaries AS( 
SELECT EmployeeNumber,
Department,
JobRole,
MonthlyIncome,
Attrition,
RANK() OVER(Partition by Department order by MonthlyIncome DESC) AS salary_rank from hr_employee)
SELECT * from ranked_salaries where salary_rank<=3
order by Department,salary_rank;