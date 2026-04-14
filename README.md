# HR Analytics — Employee Attrition Analysis

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-blue?logo=postgresql)
![PowerBI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?logo=powerbi)
![Status](https://img.shields.io/badge/Status-In%20Progress-orange)

## 📌 Project Overview

End-to-end HR Analytics project analyzing employee attrition patterns  
using PostgreSQL for data analysis and Power BI for visualization.

- **Dataset:** IBM HR Analytics Employee Attrition & Performance  
- **Source:** [Kaggle — IBM HR Analytics Dataset](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset)  
- **Size:** 1,470 employees | 35 attributes  
- **Goal:** Identify key drivers of employee attrition to help HR managers
  make data-driven retention decisions.

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| PostgreSQL 18 | Data storage, SQL analysis |
| pgAdmin | Database management & query execution |
| Power BI Desktop | Interactive dashboard |
| VS Code | SQL file editing |
| GitHub | Version control & portfolio hosting |

---

## 📁 Project Structure

hr-analytics/
├── data/ # Raw dataset (not pushed — download from Kaggle)
├── sql/
│ ├── 00_create_table.sql # Table schema
│ ├── 00_data_validation.sql # Data quality checks
│ ├── 01_attrition_by_dept.sql # Day 12
│ ├── 02_salary_analysis.sql # Day 13
│ ├── 03_window_functions.sql # Day 14
│ ├── 04_cte_analysis.sql # Day 15
│ ├── 05_tenure_analysis.sql # Day 16
│ ├── 06_overtime_analysis.sql # Day 17
│ ├── 07_performance_analysis.sql # Day 18
│ └── 08_final_summary.sql # Day 19
├── dashboard/
│ ├── hr_analytics_dashboard.pbix # Power BI file
│ └── screenshots/ # Dashboard images
└── README.md

---

## ❓ Business Questions Answered

1. What is the overall attrition rate?
2. Which departments and job roles have the highest attrition?
3. Does overtime directly correlate with attrition?
4. What salary bands see the most employee exits?
5. How does tenure and years since promotion affect attrition risk?
6. Do high performers leave more than average performers?
7. Which age groups are most at risk of leaving?
8. How does work-life balance rating relate to attrition?

---

## 📊 Key Findings

### Baseline Attrition Rate
- Overall attrition: **16.12%** (237 out of 1,470 employees left)
- Retention rate: **83.88%** (1,233 employees stayed)
- Industry benchmark for healthy attrition is ~10–15%.
  This company is slightly **above benchmark** — worth investigating why.
- For every 6 employees, roughly 1 has left the company.
  At scale (10,000 employees), that's ~1,600 exits — significant hiring cost.

> More findings will be added as queries are completed (Days 12–19).

---

## 🗂️ SQL Concepts Covered
| Concept | Business Question |
|---------|-------------------|
| Schema design, CSV import | Dataset setup & validation |
| GROUP BY, HAVING, CASE WHEN | Attrition by department & job role |
| Window Functions (ROW_NUMBER, RANK) | Salary ranking within departments |
| Window Functions (LAG, LEAD) | Tenure & promotion gap analysis |
| CTEs | Multi-step attrition breakdown |
| Subqueries + CTEs | High-risk employee profiling |
| Aggregations + FILTER | Overtime vs attrition deep dive |
| CASE WHEN + GROUP BY | Performance vs attrition matrix |
| Combined — Final summary query | Executive-level attrition report |

---

## 📈 Power BI Dashboard

**Planned Visuals:**
- Attrition rate KPI card
- Attrition by Department (bar chart)
- Attrition by Age Group (histogram)
- Monthly Income vs Attrition (box plot)
- Overtime vs Attrition (donut chart)
- Attrition by Job Role (treemap)

---

## 🚀 How to Reproduce

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset)
2. Create a PostgreSQL database called `hr_analytics`
3. Run `sql/00_create_table.sql` to create the schema
4. Import the CSV into the `hr_employee` table
5. Run `sql/00_data_validation.sql` to verify the load
6. Run queries in order from `01_` to `08_`

---

## 👤 Author

**[Mohammed Yousuf]**  
BCA Final Year | Aspiring Data Analyst  
📍 Bengaluru, India  
🔗 [LinkedIn](https://linkedin.com/in/mohammed-yousuf-aiml) | [GitHub](https://github.com/MohammedYousufCode)

---
