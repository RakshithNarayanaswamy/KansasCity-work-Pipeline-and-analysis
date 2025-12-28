# KC 311 Service Requests — End-to-End City Operations Analytics

Profiling, staging, and BI for Kansas City 311: trends, channels, departments, geography, and response times—backed by SCD Type 4 and data quality controls.

---

## Project Overview

This project builds a complete analytics pipeline for Kansas City 311 service requests:

- Profile & Prepare — Raw TSV ➜ Alteryx (profiling, type casting, trimming, null flags).
- Stage & Model — Azure SQL / SQL Server staging with lineage fields (File_Name, User_Name, Load_Date), trusted DaysToClose derivation, and SCD Type 4 dimensions (current + history).
- Visualize & Explain — Power BI and Tableau dashboards answering ten business questions across time, source, department, geography, status, response distributions, and workload efficiency.

---

## Business Questions

1. Requests Over Time — Yearly (2018–2021) and monthly trend.
2. By Source — Volume and shifts across intake channels.
3. By Department — Overall volumes and year-by-year composition.
4. Top-10 Fastest Responses (SQL) — Categorized by Category1 and Type.
5. Geography — Top-10 by ZIP, Address, and Lat/Long (exact & binned).
6. Departmental Workload — Department × Work Group (stacked/treemap).
7. Response Time Distribution — Per-department histograms/box plots; outliers/patterns.
8. Status Composition — Open/Closed/In Progress overall and by year (2018–2021).
9. Time to Closure (Category1) — Top-10 categories with longest averages.
10. Workload Efficiency — Requests vs Avg DaysToClose (scatter with quadrant lines).

---

## Key Findings (Qualitative)

- Right-skewed response times across departments; a small tail of very long cases.
- Channel mix changes visible year-to-year (digital sources vs phone).
- Departmental concentration: a few departments handle the majority of volume; some show high volume + higher AvgDays (priority bottlenecks).
- Geospatial hotspots emerge at both exact coordinates and neighborhood-level bins (~110m), revealing localized demand.
- Status composition shifts during 2018–2021, with periods of elevated open/in-progress shares.
- Category1 differences: certain categories close consistently slower than others, even after removing negatives/outliers.

Numeric KPIs are reproducible from the shared dashboards and SQL; qualitative statements above summarize observed patterns from the final visuals.

---

## Data & Sources

- Raw: 311_CallCenterServiceRequests_KansasCity.tsv (2007–Mar 2021); analysis focus: 2018–2021.
- Staging: dbo.KansasCity (or dbo.KansasCity_Clean) in Azure SQL/SQL Server via ODBC from Alteryx.
- BI: Power BI (DAX), Tableau (calculated fields/bins/percent-of-total).

---

## Data Preparation (Alteryx)

- Profiling & type inference: Auto Field, Select, Browse.
- Cleaning: Data Cleansing (trim/whitespace), Regex (punctuation), Formula/Multi-Field/Multi-Row (casts & flags).
- Dates: DateTime Parse for creation_date, closed_date.
- Derived:
  - days_to_close_num (computed from parsed dates; negatives ➜ NULL; optional capping for visuals).
  - row_has_null (row-level completeness flag).
  - Normalized categories: status/source/department/work_group/category1 (trim/case/map).
  - Numeric geo: latitude_num, longitude_num; filtered NULL/(0,0).
- Lineage: File_Name, User_Name (GetEnvironmentVariable("USERNAME")), Load_Date (DateTimeNow()).

⸻

## Data Modeling (SQL)

- Safe casting in queries with TRY_CONVERT for all duration math; exclude negative/invalid durations from SLA metrics.
- Time slicing: Year and Year-Month for trends (2018–2021 filters).
- Top-N logic: SQL for Top-10 fastest cases, Top-10 ZIPs/addresses/coordinate clusters.
- SCD Type 4:
  - Current dimension tables for standard joins.
  - History tables (effective dating + is_current) for point-in-time accuracy when departments/work groups/categories change.

---

## Visual Analytics (Power BI & Tableau)

- Time: Year columns; continuous monthly line.
  ![image](https://github.com/RakshithNarayanaswamy/KansasCity-work-Pipeline-and-analysis/blob/main/images/Screenshot%202025-12-28%20at%2012.03.43%E2%80%AFAM.png)
- Source / Department: overall bars; by-year stacked columns (also % of total).
  ![image](https://github.com/RakshithNarayanaswamy/KansasCity-work-Pipeline-and-analysis/blob/main/images/Screenshot%202025-12-28%20at%2012.05.15%E2%80%AFAM.png)
- Top-10 Fastest (SQL): sorted table (exclude NULL/negatives).
  ![image](https://github.com/RakshithNarayanaswamy/KansasCity-work-Pipeline-and-analysis/blob/main/images/Screenshot%202025-12-28%20at%2012.05.00%E2%80%AFAM.png)
- Geography:
  - ZIP (Top-10 bar), Address (Top-10 bar)
  - Lat/Long maps: exact points (Top-10 by count) & binned (~0.001° ≈ 110m) hotspots.
    ![image](https://github.com/RakshithNarayanaswamy/KansasCity-work-Pipeline-and-analysis/blob/main/images/Screenshot%202025-12-28%20at%2012.04.46%E2%80%AFAM.png)
- Response Time: department histograms (5-day bins) & box plots; optional P50/P90 measures.
  ![image](https://github.com/RakshithNarayanaswamy/KansasCity-work-Pipeline-and-analysis/blob/main/images/Screenshot%202025-12-28%20at%2012.05.26%E2%80%AFAM.png)
- Status: overall donut + by-year stacked % bars.
- Category1: Top-10 by Avg DaysToClose (optionally filter low-volume categories).
- Workload vs Efficiency: scatter (X=Requests, Y=Avg Days), labels=Department, trendline + quadrant reference lines.

---

## Data Quality: Issues & Fixes

- Missing values at scale; dates as text; negative durations (closed < creation); inconsistent categories; invalid geo (NULL/(0,0)); ZIPs not always 5-digit.
- Fixes/Plan: parsed dates; derived numeric DaysToClose; normalized categories; geo validation; lineage fields; optional visual capping of extreme durations; BI views exposing cleaned fields while retaining raw for audit.
