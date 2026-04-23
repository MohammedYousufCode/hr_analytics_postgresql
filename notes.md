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

Date: 17 April 2026
Day 14 — Tenure Bands + Promotion Gap (NTILE, RANK, Chained CTEs)

TENURE QUARTILE FINDINGS:
- New Joiners (0-3 yrs): 29.08% attrition — nearly 1 in 3 leaves early
- Early Career (3-5 yrs): drops sharply to 14.13% — survival filter kicks in
- Mid Tenure (5-9 yrs): 10.90% — mostly stable, committed employees
- Veterans (9-40 yrs): 10.35% — lowest attrition, company loyalists
- Pattern: attrition HALVES from New Joiners → Early Career (29% → 14%)
  This means onboarding and first 3 years is the critical retention window
- If company fixes Year 0-3 experience → attrition drops most dramatically

PROMOTION GAP FINDINGS:
- Multiple R&D employees: 4 years since last promotion
- Research Scientist, 5 yrs at company, 4 yrs since promotion → stuck
- Manufacturing Directors, Lab Technicians all showing 4yr promotion gap
- Promotion Overdue employees in R&D are worth flagging to HR managers

KEY BUSINESS INSIGHT:
- 107 employees left within their first 3 years (New Joiners bucket)
- That's 45% of ALL attrition (107 out of 237 total exits) happening
  in just the first 3 years → early exit is the #1 attrition problem
- Fix: better onboarding, faster first promotion, clear career paths

SQL LEARNINGS:
- NTILE(4) splits 1470 rows into 4 equal ~367-368 row buckets
- Two CTEs chained: first CTE creates tenure_quartile column,
  second CTE groups and aggregates on it
- Can't GROUP BY a window function result directly → CTE wrapper needed
- Chained CTEs = WITH cte1 AS (...), cte2 AS (SELECT FROM cte1) SELECT FROM cte2

Date: 18 April 2026
Day 15 — Overtime + Work-Life Balance (Chained CTEs)

WHAT TO LOOK FOR IN OUTPUT:

Query 1:
- Compare attrition_rate_pct where OverTime='Yes' vs OverTime='No'
- Expected: OverTime=Yes will be roughly 2x the attrition of OverTime=No
- Which department has highest overtime attrition? Likely Sales
- Check avg_salary for overtime vs non-overtime — are overtime workers
  paid more or less? If less paid AND doing overtime → double problem

Query 2:
- WorkLifeBalance=1 (Bad) + OverTime=Yes → expected highest attrition
- Does attrition_pct DROP as WLB rating improves (1→2→3→4)?
- If yes: it proves WLB rating moderates overtime impact
- avg_tenure column: do low WLB employees leave faster (lower avg_tenure)?

SQL LEARNINGS:
- CTE chain: each CTE is a named temp result — no data stored on disk
- Step 1 filters, Step 2 aggregates, Step 3 labels — clean separation
- WHERE clause in CTE (Step 1) is more readable than nested subquery filter
- CASE WorkLifeBalance WHEN 1 THEN... = shorthand for repeated CASE WHEN
- All CTEs execute top to bottom — later CTEs can reference earlier ones
- Final SELECT just picks from the last CTE — keeps main query clean

OVERTIME FINDINGS:
- ALL 3 departments are flagged CRITICAL when OverTime = Yes
- Sales overtime attrition: 37.50% vs 13.84% without overtime
  → Overtime MULTIPLIES attrition by 2.7x in Sales specifically
- R&D: 27.31% with OT vs 8.55% without → 3.2x multiplier — worst ratio
- Every single department: overtime workers leave at 2x-3x the rate
  of non-overtime workers → overtime is the single biggest attrition lever
- Avg salary for overtime vs non-overtime is almost IDENTICAL
  → employees are not being paid more for overtime → double exploitation

WORK-LIFE BALANCE FINDINGS:
- WLB=1 (Bad) + Overtime = 45.45% attrition → nearly 1 in 2 leaves
- WLB=4 (Best) attrition is 33.33% — surprisingly high
  → Even "Best" WLB rating doesn't protect overtime workers enough
  → Once overtime starts, WLB rating barely matters
- WLB=1 avg income: ₹4,644 vs WLB=3 avg: ₹6,630
  → Lowest paid overtime workers ALSO have worst work-life balance
  → Low pay + overtime + bad WLB = guaranteed attrition
- avg_tenure is similar across all WLB bands (6.0–7.1 yrs)
  → WLB doesn't affect HOW LONG before they leave, just WHETHER they leave

KEY BUSINESS RECOMMENDATION (for README/interview):
- Reducing overtime in Sales and R&D is the highest-impact
  single action this company can take to reduce attrition
- Eliminating overtime for bottom salary band employees is critical
  (WLB=1 group earns ₹4,644 avg — lowest paid AND most exploited)

Date: 21 April 2026
Day 16 — High Risk Profiling + LAG()

RISK SCORING FINDINGS:
- 370 employees flagged High/Critical Risk = 25.2% of workforce
- Top 4 Critical Risk (score=9) are ALL R&D, all earning < ₹2,400/month
- Age 27-29: youngest employees scoring highest risk → early career crisis
- EMP 741 & 1244: Research Scientists, OT=Yes, salary ~₹2,200, age 27-28
  → young, underpaid, overworked, stuck in role → textbook flight risk
- EMP 1805: HR role, score=8, no overtime yet still Critical Risk
  → low salary + low satisfaction alone drives the score up
- Scoring model validated: R&D and HR dominate Critical Risk list
  → matches Day 12 findings where these depts had highest attrition

LAG() FINDINGS:
- Healthcare Representatives showing salary INVERSION pattern
  → senior employees (more YearsAtCompany) earning LESS than juniors
  → Row 2: EMP 1766 earns ₹5,811 but previous row (junior) earned ₹6,673
  → This is salary compression — a known HR problem where new hires
    get market rate but existing employees never catch up
- 407 overtime employees analysed — LAG ran cleanly across all job roles
- prev_employee_salary=0 rows correctly excluded by WHERE clause

KEY BUSINESS INSIGHT:
- Salary compression (seniors earning less than juniors) + overtime
  = the exact combination that triggers experienced employee exits
- Company is losing institutional knowledge, not just headcount
- Risk score 9 employees should be the FIRST priority for HR intervention

WHAT TO LOOK FOR IN OUTPUT:

Query 1 (LAG):
- Look for rows where salary_gap_from_prev is NEGATIVE
  → An employee earns LESS than someone with fewer years in same role
  → These are the most likely to leave — senior but underpaid vs junior
- Check: do "Earning Less Than Junior" rows show Attrition = Yes more?
- PercentSalaryHike column: if hike % is low AND salary_progression
  is negative → this employee was ignored at appraisal time

Query 2 (Risk Score):
- How many employees are in Critical Risk (score >= 7)?
- Cross-check: of Critical Risk employees, what % have Attrition = Yes?
  → If your scoring model is good, most Attrition=Yes should be
    in High/Critical Risk buckets → model validation
- Which department has the most Critical Risk employees?
- Lowest MonthlyIncome + OverTime + low JobSatisfaction = 
  the exact profile that always appears in attrition research

SQL LEARNINGS:
- LAG(col, 1, 0): third argument = default when no previous row exists
  → prevents NULL in first row of each partition
- WHERE prev_employee_salary > 0 removes those first-row NULLs cleanly
- Risk scoring with stacked CASE WHEN additions is a standard
  technique in HR analytics, credit scoring, and fraud detection
- RANK() inside second CTE ranks employees after scoring is done
  → clean separation: score first, rank second

  Date: 22 April 2026
Day 17 — Performance Rating vs Attrition + Satisfaction Matrix

WHAT TO LOOK FOR IN OUTPUT:

Query 1:
- Does PerformanceRating=4 still show meaningful attrition?
  If yes → company is losing good performers too
- Compare avg_job_satisfaction and avg_environment_satisfaction
  by PerformanceRating
- If high performers have decent ratings but still leave,
  the issue may be overtime, promotion gap, or pay compression

Query 2:
- Which JobSatisfaction + EnvironmentSatisfaction combo has highest attrition?
- Expected: low job satisfaction + low environment satisfaction = worst case
- Focus only on combinations with at least 20 employees
  → avoids fake high percentages on tiny groups
- Check avg_income too:
  if low-satisfaction groups also earn less,
  then dissatisfaction may be tied to compensation

SQL LEARNINGS:
- FILTER is cleaner than repeating SUM(CASE WHEN ...)
- COUNT(*) FILTER (WHERE Attrition='Yes') is the modern PostgreSQL style
- You can calculate multiple conditional metrics in one grouped query
- CTE 1 builds the matrix, CTE 2 labels the risk level

PERFORMANCE FINDINGS — THE SHOCKING PART:
- Dataset has ONLY PerformanceRating 3 and 4 — no 1s or 2s
  → IBM rated everyone Excellent (3) or Outstanding (4)
  → This is a known dataset limitation — likely a data collection bias
- Rating 3 attrition: 16.08% | Rating 4 attrition: 16.37%
  → Virtually IDENTICAL — performance rating has zero predictive value here
- Outstanding performers (rating=4) leave at a HIGHER rate than Excellent (3)
  → The best employees are leaving more than average — serious problem
- Outstanding performers earn LESS on average (₹6,313 vs ₹6,537)
  → Best performers being paid less → obvious reason they're leaving
- avg_job_satisfaction is 2.73 for BOTH groups — mid-scale, not high
  → Even high performers are only moderately satisfied

SATISFACTION MATRIX FINDINGS:
- Worst combination: JobSat=1 + EnvSat=1 → 37.74% attrition (Critical)
- Second worst: JobSat=2 + EnvSat=1 → 34.04% — EnvSat=1 is the killer
  → Low environment satisfaction is more damaging than low job satisfaction
- Row 5: JobSat=1 + EnvSat=4 → only 18.39%
  → Good environment compensates somewhat for low job satisfaction
- Avg income for Critical group (₹6,158–₹7,358) is not low
  → These employees earn decent money but STILL leave
  → Confirms: money alone doesn't retain employees with bad environment

KEY INTERVIEW-READY INSIGHT:
- Performance rating is a POOR predictor of attrition in this dataset
- Environment satisfaction (physical/cultural workplace) predicts attrition
  better than job satisfaction alone
- Best retention investment: fix the work environment first,
  then address job role satisfaction

Date: 23 April 2026
Day 18 — Executive Summary Query (Full Pipeline)

SALARY FAIRNESS PATTERN — THE MOST IMPORTANT FINDING:
- Rows 1,2,3,5,8: salary_fairness = 'Leavers Underpaid'
  → These are ALL low-to-mid salary roles (₹2,600–₹4,235)
  → Leavers earned LESS than their peers who stayed
  → Pay inequity at entry-mid level is directly causing exits
- Rows 4,6,7,9,10: salary_fairness = 'Leavers Overpaid'
  → These are senior/high-pay roles (₹7,000–₹19,000)
  → Leavers actually earned MORE than stayers
  → These people left despite being well-paid → NOT a money problem
  → For senior roles: career growth, autonomy, or culture is the issue

THE TWO-TIER ATTRITION PROBLEM:
- Tier 1 (Junior roles): leaving because underpaid vs peers
  → Fix: pay equity audit, salary band enforcement
- Tier 2 (Senior roles): leaving despite being overpaid
  → Fix: career development, promotion paths, role enrichment

ATTRITION CONCENTRATION:
- Top 3 roles (Sales Rep, Lab Tech, HR) account for:
  33+62+12 = 107 exits out of 237 total = 45% of ALL company attrition
  → Fix just these 3 roles → almost halve company attrition
- Research Director: only 2.50% attrition → benchmark for stability

OVERTIME OBSERVATION:
- Overtime% is 23-33% across ALL roles regardless of attrition rate
  → Overtime is company-wide, not role-specific
  → But combined with low salary → triggers attrition in junior roles

QUERY ARCHITECTURE NOTE:
- 4-step CTE pipeline: metrics → satisfaction → join → rank+classify
- JOIN between two CTEs on Department+JobRole is valid PostgreSQL
- attrition_rate_pct column still showing full decimals → note for self:
  use ROUND(..., 2) wrapped around the full expression next time


WHAT TO LOOK FOR:
- Which job role has rank=1 (highest attrition) in each department?
- salary_fairness = 'Leavers Underpaid' → confirms pay is driving exits
- salary_fairness = 'Leavers Overpaid' → attrition is NOT about money
  → look at their WLB/satisfaction scores instead
- risk_classification: count how many roles are Critical vs Stable
- avg_yrs_since_promotion: roles with 3+ years AND high attrition
  → promotion stagnation is the root cause there
- Compare avg_tenure of high-risk vs stable roles
  → if high-risk roles have shorter avg_tenure → early exit confirmed

QUERY ARCHITECTURE:
- CTE 1 (base_metrics): all attrition and salary numbers
- CTE 2 (satisfaction_metrics): all satisfaction and OT numbers
- CTE 3 (combined): JOIN the two CTEs on Dept + JobRole
- CTE 4 (ranked): add RANK() window function + CASE labels
- Final SELECT: filter and present cleanly
- This is a 4-step CTE pipeline — the most complex query in the project
- JOIN between two CTEs is valid PostgreSQL — treat them like tables