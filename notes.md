Date: 14 April 2026
Day 11 — PostgreSQL Setup & Data Load

- Dataset: 1,470 employees, 35 columns — IBM HR Attrition
- Overall attrition rate: 16.12% (237 left, 1233 stayed)
- Industry healthy benchmark is 10–15% → this company is ABOVE benchmark
- For every 6 employees, 1 has left → at 10,000 scale = 1,600 exits
- Zero null EmployeeNumbers → data is clean, no import errors
- Used \COPY not COPY → client-side import, no superuser needed
- EmployeeNumber set as PRIMARY KEY → no duplicate employees possible
- Attrition column is VARCHAR(3) storing 'Yes'/'No' → need CASE WHEN 
  to count it numerically in every query

  Date: 15 April 2026
Day 12 — Attrition by Department & Job Role

DEPARTMENT FINDINGS:
- Sales: 20.63% attrition → 1 in 5 Sales employees leaving
- Human Resources: 19.05% → even HR staff are leaving (cultural issue?)
- R&D: 13.84% → lowest, but still above industry benchmark

JOB ROLE FINDINGS:
- Sales Representatives: 39.76% → nearly 2 in 5 left (CRISIS level)
- Sales Rep attrition is 2.5x the company average of 16.12%
- Lab Technicians: 23.94% → High Risk
- Human Resources role: 23.08% → High Risk
- Managers: only 4.90% → senior roles are very stable
- Pattern: entry-to-mid level roles bleed talent, senior roles don't

SQL LEARNINGS:
- CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END → converts text to countable number
- HAVING COUNT(*) >= 50 → filters AFTER grouping (WHERE filters BEFORE)
- Without HAVING filter → a 3-person role with 1 exit = 33% (misleading)
- HAVING is your credibility filter in any % analysis

Date: 16 April 2026
Day 13 — Salary Analysis with Window Functions

KEY INSIGHT:
- Sales Manager EMP#1038, salary ₹19,845 (rank 2 in Sales) → Attrition = YES
- A top earner still left → money alone is NOT why people stay
- This breaks the assumption that "just pay them more" solves attrition

SALARY FINDINGS:
- HR dept avg salary: ₹6,654 → lowest of all 3 departments
- HR Manager earning ₹19,717 is ₹13,062 ABOVE dept average
- Massive internal pay gap within HR department
- All top 3 earners across all departments are Managers → seniority = salary

SQL LEARNINGS:
- GROUP BY collapses rows → you lose individual detail
- WINDOW FUNCTION keeps all 1470 rows + adds group calculation alongside
- AVG() OVER(PARTITION BY Department) → runs separate avg per dept in one pass
- PARTITION BY = GROUP BY but rows stay intact
- RANK() gives same number to ties → (1,1,3) not (1,2,3)
- ROW_NUMBER() always unique → (1,2,3) even for ties
- For salary analysis always use RANK() → equal pay = equal rank
- Cannot use window function alias in WHERE clause directly
- Solution: wrap in CTE first, then filter → standard industry pattern