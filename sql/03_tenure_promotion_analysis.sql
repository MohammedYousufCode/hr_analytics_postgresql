-- Query 1: Promotion gap analysis
-- Business Question: Does a long promotion gap drive attrition?

SELECT EmployeeNumber,
Department,
JobRole,
YearsAtCompany,
YearsSinceLastPromotion,
YearsInCurrentRole,
CASE WHEN YearsSinceLastPromotion>=3 AND YearsInCurrentRole>=3 THEN 'Promotion Overdue'
WHEN YearsSinceLastPromotion>=1 AND YearsInCurrentRole>=2 THEN 'Promotion Pending'
ELSE 'Recently Promoted' END AS promotion_status,
RANK() OVER(PARTITION BY Department ORDER BY YearsSinceLastPromotion DESC) AS promotion_wait_rank 
from hr_employee
ORDER BY YearsSinceLastPromotion DESC,Department;

-- Query 2: Tenure quartile vs attrition
-- Business Question: Do new employees or veterans leave more?
WITH tenure_bands AS(
SELECT EmployeeNumber,
Department,
jobRole,
YearsAtCompany,
MonthlyIncome,
Attrition,
NTILE(4) OVER(ORDER BY YearsAtCompany ASC) AS tenure_quartile FROM hr_employee),
quartile_summary AS( SELECT tenure_quartile,
MIN(YearsAtCompany) AS min_years,
MAX(YearsAtCompany) AS max_years,COUNT(*) AS total_employees,
SUM(CASE WHEN Attrition = 'Yes' Then 1 ELSE 0 END)AS employees_left,
ROUND(SUM(CASE WHEN Attrition = 'Yes' Then 1 ELSE 0 END)*100.0/COUNT(*),2) AS attrition_rate_pct 
from tenure_bands
GROUP BY tenure_quartile)
SELECT tenure_quartile,
min_years as tenure_from_years,
max_years as tenure_to_years,
total_employees,
employees_left,
attrition_rate_pct,
CASE WHEN tenure_quartile=1 THEN 'New Joiners'
WHEN tenure_quartile=2 then 'Early Career'
WHEN tenure_quartile=3 THEN 'Mid tenure'
WHEN tenure_quartile=4 THEN 'Veterans'
END as tenure_band
FRom quartile_summary
ORDER BY tenure_quartile;
