# Day 7: Joins and Subqueries – MySQL 8.4 LTS

## Overview
This directory contains complete solutions, relational database schemas, production seed data, complex SQL scripts (`advanced_reports.sql`), and analytical reports for **Day 7 – Joins and Subqueries** of the Hexaware training program.

The assignments cover advanced relational operations, including multi-table inner and outer joins, self joins, uncorrelated and correlated subqueries, set membership and quantification operators (`IN`, `NOT IN`, `EXISTS`, `NOT EXISTS`, `ANY`, `ALL`), nested subqueries, and enterprise performance optimizations.

---

## Directory Structure

```
Day-7/
├── README.md                                                 # Master overview for Day 7
├── Set1_LogisticsShipmentAnalysis/
│   ├── advanced_reports.sql                                  # Complete DDL, seed data & 10 business queries + rewrites
│   └── join_choice_and_analysis_report.md                    # Join choice rationale table & performance comparison
├── Set2_BankLoanPortfolio/
│   ├── advanced_reports.sql                                  # Complete DDL, seed data & 10 loan portfolio queries
│   └── subquery_justification_report.md                      # Subquery design justification & circular risk analysis
└── Set3_RetailReturnsAndRefunds/
    ├── advanced_reports.sql                                  # Complete DDL, seed data & 10 retail returns queries
    └── scalability_and_null_report.md                        # Expected outputs, NULL pitfall analysis & 100x scaling
```

---

## Assignment Sets Summary

### Set 1 – Logistics Shipment Analysis
- **Domain:** Global logistics network tracking hubs, vehicles, drivers, shipments, and delivery milestones.
- **Key Concepts:**
  - INNER, LEFT, RIGHT, and Self Joins (vehicle mileage comparisons, driver hierarchies).
  - Subqueries with `IN`, `EXISTS`, `ANY`, and `ALL` for high-value and delayed shipment tracking.
  - Subquery-to-Join query rewrites with execution plan and readability evaluations.
  - Nested subquery determining the second-highest shipping cost per dispatch hub.
  - Comprehensive Join-Choice Rationale Table.
- **Key Deliverables:**
  - [`Set1_LogisticsShipmentAnalysis/advanced_reports.sql`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-7/Set1_LogisticsShipmentAnalysis/advanced_reports.sql)
  - [`Set1_LogisticsShipmentAnalysis/join_choice_and_analysis_report.md`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-7/Set1_LogisticsShipmentAnalysis/join_choice_and_analysis_report.md)

---

### Set 2 – Bank Loan Portfolio
- **Domain:** Retail banking operations covering borrowers, branches, loan facilities, guarantors, and repayment transactions.
- **Key Concepts:**
  - Default risk detection (>3 overdue instalments).
  - Multi-branch exposure and self joins identifying guarantors who are active borrowers.
  - Identification of dormant branches with no loan disbursements.
  - Correlated subqueries filtering borrowers whose exposure exceeds branch averages.
  - `EXISTS` and `NOT EXISTS` tracking borrowers with no repayments in the last 60 days.
  - Nested subquery locating branches whose peak loan exceeds the average of all branch peak loans.
  - Systemic circular risk analysis (guarantor cross-exposure).
- **Key Deliverables:**
  - [`Set2_BankLoanPortfolio/advanced_reports.sql`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-7/Set2_BankLoanPortfolio/advanced_reports.sql)
  - [`Set2_BankLoanPortfolio/subquery_justification_report.md`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-7/Set2_BankLoanPortfolio/subquery_justification_report.md)

---

### Set 3 – Retail Returns and Refunds
- **Domain:** Omni-channel retail operations monitoring stores, products, customer sales, return requests, and refund disbursements.
- **Key Concepts:**
  - High return rate products (>10% return rate) and pending un-refunded returns.
  - Top refund stores and store management hierarchy (self join).
  - Exhaustive proof and demonstration of the **Three-Valued Logic NULL Pitfall** (`NOT IN` vs `NOT EXISTS`).
  - Regional store comparisons using `ANY` and `ALL`.
  - Nested subqueries for customer category return spending and second-highest refunded products per category.
  - Enterprise 100x data volume scaling architectural plan (indexing, hash joins, partitioning, rollup summary tables).
- **Key Deliverables:**
  - [`Set3_RetailReturnsAndRefunds/advanced_reports.sql`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-7/Set3_RetailReturnsAndRefunds/advanced_reports.sql)
  - [`Set3_RetailReturnsAndRefunds/scalability_and_null_report.md`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-7/Set3_RetailReturnsAndRefunds/scalability_and_null_report.md)

---

## Execution Instructions (MySQL 8.4 LTS)
To execute any set's SQL script, connect to your MySQL 8.4 instance and source the file:
```bash
# Set 1 - Logistics
mysql -u <username> -p < Day-7/Set1_LogisticsShipmentAnalysis/advanced_reports.sql

# Set 2 - Banking
mysql -u <username> -p < Day-7/Set2_BankLoanPortfolio/advanced_reports.sql

# Set 3 - Retail
mysql -u <username> -p < Day-7/Set3_RetailReturnsAndRefunds/advanced_reports.sql
```
Each script is self-contained: it drops and recreates the target database, sets up primary and foreign key constraints, populates realistic seed data, and executes all analytical queries.
