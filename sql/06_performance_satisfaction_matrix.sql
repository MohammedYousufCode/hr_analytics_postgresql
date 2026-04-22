-- Query 1: Performance rating vs attrition
-- Business Question: Are high performers also leaving?

select PerformanceRating,
COUNT(*) AS total_employees,
COUNT(*) FILTER(WHERE Attrition = 'Yes') as employees_left,
COUNT(*) FILTER(WHERE Attrition = 'No') as employee_stayed,
ROUND(COUNT(*) FILTER(WHERE Attrition = 'Yes')*100.0/COUNT(*),2) as attrition_rate_pct,
ROUND(AVG(MonthlyIncome),2)as avg_monthly_income,
ROUND(AVG(JobSatisfaction),2)as avg_job_satisfaction,
ROUND(AVG(EnvironmentSatisfaction),2)as avg_env_satisfaction
from hr_employee
GROUP BY PerformanceRating
Order by PerformanceRating;

-- Query 2: Job satisfaction x environment satisfaction matrix
-- Business Question: Which satisfaction combinations are most risky?

WITH satisfaction_matrix as (select JobSatisfaction,
EnvironmentSatisfaction,
COUNT(*) AS total_employees,
COUNT(*) FILTER(WHERE Attrition = 'Yes') as employees_left,
COUNT(*) FILTER(WHERE Attrition = 'No') as employees_stayed,
ROUND(COUNT(*) FILTER(WHERE Attrition = 'Yes')*100.0/COUNT(*),2) as attrition_rate_pct,
ROUND(AVG(MonthlyIncome),2)as avg_income
FROM hr_employee
GROUP BY JobSatisfaction,EnvironmentSatisfaction),
risk_labeled as(SELECT *,
CASE WHEN attrition_rate_pct>=25 THEN 'Critical'
WHEN attrition_rate_pct>=15 THEN 'High'
WHEN attrition_rate_pct>=10 THEN 'Moderate'
ELSE 'Stable' End AS risk_band from satisfaction_matrix)
SELECT JobSatisfaction,
EnvironmentSatisfaction,
total_employees,
employees_left,
employees_stayed,
attrition_rate_pct,
avg_income,
risk_band
FROM risk_labeled
WHERE total_employees>=20
ORDER BY attrition_rate_pct DESC,total_employees DESC;