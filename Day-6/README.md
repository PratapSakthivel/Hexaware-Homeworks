# Day 6 – Functions, Aggregation, Grouping and Joins (MySQL 8.4 LTS)

**Author:** Pratap Sakthivel  
**Repository:** [PratapSakthivel/Hexaware-Homeworks](https://github.com/PratapSakthivel/Hexaware-Homeworks)  
**Topics Covered:** Data Integrity and Functions · Aggregate Functions, GROUP BY and HAVING · Advanced Joins (INNER, LEFT, CROSS) · NULL Behavior in Aggregates · Date/String Manipulation · ARPU Metrics  

---

## Directory Overview

```
Day-6/
├── README.md                                   # Master overview of Day 6 analytics & SQL reports
├── Set1_RetailSalesReporting/
│   ├── reports.sql                             # 8 sales queries, string/date functions, NULL analysis, WHERE vs HAVING
│   └── output_and_analysis_report.md           # Tabular expected results, NULL breakdown, WHERE vs HAVING guide
│
├── Set2_InsurancePolicyReporting/
│   ├── reports.sql                             # 8 policy/claim queries, loss-ratio HAVING, INNER/LEFT/CROSS joins
│   └── output_and_analysis_report.md           # Tabular expected results, loss-ratio breakdown, join justifications
│
└── Set3_TelecomUsageAndBilling/
    ├── reports.sql                             # 8 telecom usage/billing queries, overage detection, ARPU by circle
    └── output_and_analysis_report.md           # Tabular expected results, IFNULL/COALESCE analysis, revenue matrix
```

---

## Summary of Completed Sets & SQL Deliverables

### 1. [Set 1: Retail Sales Reporting](./Set1_RetailSalesReporting/reports.sql)
- **Business Scope:** Daily and monthly intelligence reports from `orders`, `order_items`, `customers`, and `products`.
- **The 8 Queries Implemented:**
  1. Top-5 products by total gross revenue
  2. Month-wise sales revenue and volume
  3. Loyal customers with more than 3 orders (`HAVING COUNT > 3`)
  4. Average basket value per customer city
  5. Orders without payment (`LEFT JOIN` checking for UNPAID / NULL payment)
  6. Inactive customers with zero orders
  7. Product-category revenue percentage contribution
  8. Peak sales day with highest gross transaction value
- **Functions & Deep-Dive:** `UPPER`, `CONCAT`, `DATEDIFF`, `DATE_FORMAT`, `ROUND`, `FORMAT`. Detailed analysis of NULL behavior across `COUNT(*)`, `COUNT(col)`, `SUM`, and `AVG`.
- **Documentation:** [`output_and_analysis_report.md`](./Set1_RetailSalesReporting/output_and_analysis_report.md)

---

### 2. [Set 2: Insurance Policy Reporting](./Set2_InsurancePolicyReporting/reports.sql)
- **Business Scope:** Actuarial and portfolio administration analytics across `policies`, `customers`, `products`, `agents`, and `claims`.
- **The 8 Queries Implemented:**
  1. Policies expiring in the next 30 days (`BETWEEN` with `DATE_ADD`)
  2. Total premium written per product line
  3. Multi-policyholder accounts (`HAVING COUNT > 1`)
  4. Claim loss ratio per product (`SUM(settled_claims) / SUM(premium) * 100`)
  5. Loss-free policies without any claim submissions (`LEFT JOIN` where claim IS NULL)
  6. Average annual premium segmented across age bands (`CASE` with `TIMESTAMPDIFF`)
  7. Monthly new business premium written
  8. Top-5 sales agents by premium volume
- **Functions & Joins:** Masked policy strings (`CONCAT`, `SUBSTRING`), age-band segmentation, `HAVING claim_ratio > 60%`. Rigorous technical justification for `INNER JOIN`, `LEFT OUTER JOIN`, and `CROSS JOIN`.
- **Documentation:** [`output_and_analysis_report.md`](./Set2_InsurancePolicyReporting/output_and_analysis_report.md)

---

### 3. [Set 3: Telecom Usage and Billing](./Set3_TelecomUsageAndBilling/reports.sql)
- **Business Scope:** Network subscriber telemetry, quota overages, and financial billing across `subscribers`, `plans`, `call_records`, and `invoices`.
- **The 8 Queries Implemented:**
  1. Total call minutes and average duration per plan
  2. Subscribers exceeding their high-speed data quota (`HAVING sum_mb / 1024 > quota`)
  3. Month-wise telecom billing revenue
  4. Invoices overdue by more than 15 days with collection priority tagging
  5. Dormant subscriber SIMs with zero usage records
  6. Average Revenue Per User (ARPU) by telecom circle
  7. Plan popularity and market share percentage
  8. Top-10 heavy data consumers across networks
- **Functions & Robustness:** Invoice number formatting, due-date calculations with `DATEDIFF`. Comprehensive comparison of `NULL` handling in `SUM`/`AVG` using `IFNULL()` and `COALESCE()` to eliminate financial ledger discrepancies.
- **Documentation:** [`output_and_analysis_report.md`](./Set3_TelecomUsageAndBilling/output_and_analysis_report.md)
