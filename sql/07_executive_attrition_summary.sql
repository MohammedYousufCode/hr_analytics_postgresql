-- HR Analytics: Executive Attrition Summary Report
-- Combines: CTEs, Window Functions, FILTER, CASE WHEN, RANK
-- Business Question: Full attrition profile per dept & job role
-- Author: Mohammed Yousuf | Date: 2026-04-23

with base_metrics as (SELECT Department,JobRole,COUNT(*) as total_employees,
COUNT(*) FILTER(WHERE Attrition='Yes')as employees_left,
COUNT(*) FILTER(WHERE Attrition='No')as employees_stayed,
COUNT(*) FILTER(WHERE Attrition='Yes')*100.0/COUNT(*)as attrition_rate_pct,
ROUND(AVG(MonthlyIncome),2)as avg_salary,
ROUND(AVG(MonthlyIncome)FILTER(WHERE Attrition='Yes'),2)as avg_salary_leavers,
ROUND(AVG(MonthlyIncome)FILTER(WHERE Attrition='No'),2)as avg_salary_stayers
FROM hr_employee
GROUP BY Department,JobRole),

satisfaction_matrix as(SELECT Department,JobRole,
ROUND(AVG(JobSatisfaction),2)as avg_job_satisfaction,
ROUND(AVG(EnvironmentSatisfaction),2)as avg_env_satisfaction,
ROUND(AVG(WorkLifeBalance),2)as avg_wlb,
COUNT(*) FILTER(WHERE OverTime='Yes')as overtime_count,
ROUND(COUNT(*) FILTER(WHERE OverTime='Yes')*100.0/COUNT(*),2)as overtime_pct,
ROUND(AVG(YearsSinceLastPromotion),1)as avg_years_since_promotion,
ROUND(AVG(YearsAtCompany),1)as avg_tenure FROM hr_employee GROUP BY Department,JobRole),

combined as(select b.Department,b.JobRole,b.total_employees,b.employees_left,b.employees_stayed,
b.attrition_rate_pct,b.avg_salary,b.avg_salary_leavers,b.avg_salary_stayers,s.avg_job_satisfaction,
s.avg_env_satisfaction,s.avg_wlb,s.overtime_count,s.overtime_pct,s.avg_years_since_promotion,
s.avg_tenure 
FROM base_metrics b JOIN satisfaction_matrix s ON b.Department= s.Department AND b.JobRole=s.JobRole),

ranked as(SELECT *,RANK() OVER(Partition by Department order by attrition_rate_pct desc)as dept_attrition_rank,
CASE WHEN avg_salary_leavers<avg_salary_stayers THEN 'Leavers Underpaid' when avg_salary_leavers>avg_salary_stayers
THEN 'Leavers Overpaid' else 'Eqaul pay' END as salary_fairness,
CASE WHEN attrition_rate_pct>=25 AND overtime_pct>=30 THEN 'Critical - High OT + High Attrition'
WHEN attrition_rate_pct>=25 THEN 'High Attrition'
WHEN attrition_rate_pct>=15 AND avg_job_satisfaction<2.5 then 'High Risk - Low Satisfaction'
WHEN attrition_rate_pct>=15 then 'High Risk'
WHEN attrition_rate_pct>=10 then 'Moderate Risk'

ELSE 'Stable' end as risk_classification from combined)
SELECT Department,JobRole,total_employees,employees_left,attrition_rate_pct,avg_salary,avg_salary_leavers,
avg_salary_stayers,salary_fairness,overtime_pct,avg_job_satisfaction,avg_env_satisfaction,avg_wlb,avg_years_since_promotion,
avg_tenure,dept_attrition_rank,risk_classification from ranked where total_employees>=30 order by attrition_rate_pct desc,Department;
