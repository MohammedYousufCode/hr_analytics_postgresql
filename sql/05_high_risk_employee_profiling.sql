-- Query 1: Salary lag analysis for overtime employees
-- Business Question: Are longer-tenure overtime employees falling behind on salary?

WITH overtime_ranked AS(
    SELECT EmployeeNumber,Department,JobRole,YearsAtCompany,MonthlyIncome,
    OverTime,Attrition,PercentSalaryHike,
    LAG(MonthlyIncome,1,0)
    OVER(Partition By JobRole Order By YearsAtCompany ASC) AS prev_employee_salary,
    LAG(YearsAtCompany,1,0)
    OVER(PARTITION BY JobRole ORDER BY YearsAtCompany ASC) AS prev_employee_tenure 
    From hr_employee WHERE OverTime = 'Yes'
)
SELECT EmployeeNumber,Department,JobRole,YearsAtCompany,MonthlyIncome,
prev_employee_salary,prev_employee_tenure,
MonthlyIncome-prev_employee_salary AS salary_gap_from_prev,PercentSalaryHike,
Attrition,
CASE WHEN (MonthlyIncome - prev_employee_salary)<0 THEN 'Earning less than junior'
WHEN(MonthlyIncome - prev_employee_salary)=0 THEN 'Same As Junior'  
ELSE 'Earning More Than Junior' END AS salary_progression 
FROM overtime_ranked WHERE prev_employee_salary>0 OrDER BY JobRole,YearsAtCompany ASC; 

-- Query 2: Multi-factor attrition risk scoring
-- Business Question: Which active employees show the most compounding risk factors?

WITH risk_scoring as (select EmployeeNumber,Department,JobRole,Age,MonthlyIncome,OverTime,WorkLifeBalance,
YearsSinceLastPromotion,YearsInCurrentRole, JobSatisfaction,EnvironmentSatisfaction,NumCompaniesWorked,Attrition,
(CASE WHEN OverTime = 'Yes' Then 1 Else 0 END)+
(CASE WHEN WorkLifeBalance=1 THEN 2 ELSE 0 END)+
(CASE WHEN WorkLifeBalance=2 THEN 1 ELSE 0 end)+
(CASE WHEN YearsSinceLastPromotion>=3 THEN 1 ELSE 0 END)+
(CASE WHEN YearsInCurrentRole>=3 THEN 1 ELSE 0 END)+
(CASE WHEN JobSatisfaction<=2 THEN 2 ELSE 0 END)+
(CASE WHEN EnvironmentSatisfaction<=2 THEN 1 ELSE 0 END)+
(CASE WHEN NumCompaniesWorked>=4 THEN 1 ELSE 0 END)+
(CASE WHEN MonthlyIncome<3000 THEN 2 ELSE 0 END)AS risk_score from hr_employee),
risk_labeled as (SELECT *,
CASE WHEN risk_score >= 7 THEN 'Critical Risk'
WHEN risk_score >= 5 THEN 'High Risk'
WHEN risk_score >= 3 THEN 'Medium Risk' ELSE 'Low Risk' END as risk_category,
RANK() OVER(Partition by Department order by risk_score desc) AS dept_risk_rank from risk_scoring)
SELECT EmployeeNumber,Department,JobRole,Age,MonthlyIncome,OverTime,risk_score,risk_category,dept_risk_rank,Attrition 
FROM risk_labeled where risk_category IN('Critical Risk','High Risk') order by risk_score desc,Department;