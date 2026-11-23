# Day 9: Views, Stored Procedures, Functions and Cursors – MySQL 8.4 LTS

## Overview
This directory contains complete production-ready solutions, database schemas, stored procedures, user-defined functions, views with check options, cursor handlers, and performance benchmarks for **Day 9** of the Hexaware training program.

---

## Directory Structure

```
Day-9/
├── README.md                                                 # Master overview for Day 9
├── Set1_RetailOrderFulfilment/
│   ├── views.sql                                             # Views (vw_order_summary, vw_low_stock WITH CHECK OPTION)
│   ├── procedures.sql                                        # sp_place_order with rollback handler & fn_order_total_with_tax
│   ├── cursor.sql                                            # Aged orders cursor with NOT FOUND handler vs set-based rewrite
│   └── cursor_vs_setbased_comparison.md                     # Technical report on Functions vs Procedures & Cursor performance
├── Set2_InsurancePremiumProcessing/
│   ├── views.sql                                             # vw_policy_due hiding sensitive PII & medical risk columns
│   ├── procedures.sql                                        # sp_renew_policy with INOUT counter & fn_premium_with_no_claim_discount
│   ├── cursor.sql                                            # Lapsed policy cursor with audit log vs set-based update
│   └── comparison_note.md                                   # Parameter semantics (INOUT) & cursor vs set-based benchmark
└── Set3_TelecomLowBalanceFollowup/
    ├── views.sql                                             # vw_prepaid_subscribers & vw_recharge_summary
    ├── procedures.sql                                        # sp_recharge with SQLEXCEPTION handler & fn_validity_days_left
    ├── cursor.sql                                            # Low balance notification cursor vs set-based INSERT ... SELECT
    └── timing_comparison.md                                  # Empirical timing analysis (105x speedup proof)
```

---

## Quick Execution Guide
Connect to your MySQL 8.4 LTS instance and execute any set:
```bash
# Set 1 - Retail Fulfilment
mysql -u <user> -p < Day-9/Set1_RetailOrderFulfilment/views.sql
mysql -u <user> -p < Day-9/Set1_RetailOrderFulfilment/procedures.sql
mysql -u <user> -p < Day-9/Set1_RetailOrderFulfilment/cursor.sql

# Set 2 - Insurance Premium
mysql -u <user> -p < Day-9/Set2_InsurancePremiumProcessing/views.sql
mysql -u <user> -p < Day-9/Set2_InsurancePremiumProcessing/procedures.sql
mysql -u <user> -p < Day-9/Set2_InsurancePremiumProcessing/cursor.sql

# Set 3 - Telecom Follow-up
mysql -u <user> -p < Day-9/Set3_TelecomLowBalanceFollowup/views.sql
mysql -u <user> -p < Day-9/Set3_TelecomLowBalanceFollowup/procedures.sql
mysql -u <user> -p < Day-9/Set3_TelecomLowBalanceFollowup/cursor.sql
```
