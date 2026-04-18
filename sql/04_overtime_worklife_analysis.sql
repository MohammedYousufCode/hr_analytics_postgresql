-- Query 1: Overtime vs Attrition analysis by department
-- Business Question: Does overtime drive attrition? Which dept is worst?

WITH overtime_base AS (
SELECT Department,OverTime,Attrition,MonthlyIncome,WorkLifeBalance,COUNT(*) AS Employee_count 
FROM hr_employee GROUP BY Department,OverTime,Attrition,MonthlyIncome,WorkLifeBalance),

overtime_summary AS(
SELECT Department,
Overtime,
COUNT(*) AS total_employees,
SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS attrition_rate_pct,
ROUND(AVG(MonthlyIncome),2) AS avg_salary FROM hr_employee GROUP BY Department,OverTime)

SELECT Department,
OverTime,
total_employees,
employees_left,
attrition_rate_pct,
avg_salary,
CASE WHEN OverTime = 'Yes' and attrition_rate_pct>25 THEN 'Critical'
WHEN OverTime = 'Yes' and attrition_rate_pct>15 THEN 'High Risk'
ELSE 'Stable' END AS risk_flag FROM overtime_summary ORDER BY OverTime DESC,attrition_rate_pct DESC;

-- Query 2: Work-life balance rating vs attrition (overtime employees only)
-- Business Question: Does poor WLB rating compound overtime attrition risk?

WITH overtime_employees AS(
SELECT EmployeeNumber,
Department,JobRole,OverTime,WorkLifeBalance,MonthlyIncome,Attrition,YearsAtCompany 
from hr_employee WHERE OverTime='Yes'),

wlb_grouped AS (
SELECT WorkLifeBalance,COUNT(*) AS total,
SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS attrition_pct,
ROUND(AVG(MonthlyIncome),2) AS avg_income,
ROUND(AVG(YearsAtCompany),1)AS avg_tenure FROM overtime_employees GROUP BY WorkLifeBalance),
wlb_labeled AS (SELECT WorkLifeBalance,
CASE WorkLifeBalance WHEN 1 THEN 'Bad'
WHEN 2 THEN 'Good'
WHEN 3 THEN 'Better'
WHEN 4 THEN 'Best' END AS wlb_label,total,left_count,attrition_pct,avg_income,avg_tenure 
FROM wlb_grouped)

SELECT * FROM wlb_labeled ORDER BY WorkLifeBalance ASC;