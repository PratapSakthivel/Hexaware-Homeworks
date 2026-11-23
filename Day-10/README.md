# Day 10: Triggers – MySQL 8.4 LTS

## Overview
This directory contains complete production-ready solutions, database schemas, BEFORE and AFTER row-level triggers, audit logging tables, multi-row batch tests, trigger limitation notes, and JDBC integration patterns for **Day 10** of the Hexaware training program.

---

## Directory Structure

```
Day-10/
├── README.md                                                 # Master overview for Day 10
├── Set1_RetailPriceChangeAudit/
│   ├── triggers.sql                                          # AFTER UPDATE price audit & BEFORE UPDATE below-cost guard
│   ├── test_evidence.sql                                     # Single/multi-row updates, SIGNAL 45000 test & information_schema
│   └── pitfalls_note.md                                      # Hidden logic risks, mutating cascades & app-tier alternatives
├── Set2_BankAccountBalanceGuard/
│   ├── triggers.sql                                          # AFTER INSERT/UPDATE/DELETE audit & BEFORE UPDATE negative guard
│   ├── test_evidence.sql                                     # 5-account batch update test & all-or-nothing rollback proof
│   └── trigger_limitations_note.md                           # Why MySQL has no INSTEAD OF trigger & derived column updates
└── Set3_HospitalBedCapacityControl/
    ├── triggers.sql                                          # BEFORE INSERT capacity block & AFTER audit/occupancy sync
    ├── test_evidence.sql                                     # Multi-row batch INSERT testing & capacity overflow proof
    └── justification_note.md                                 # CHECK vs Triggers vs Procedures & Java JDBC testing pattern
```

---

## Quick Execution Guide
Connect to MySQL 8.4 LTS and execute:
```bash
# Set 1 - Retail Price Audit
mysql -u <user> -p < Day-10/Set1_RetailPriceChangeAudit/triggers.sql
mysql -u <user> -p < Day-10/Set1_RetailPriceChangeAudit/test_evidence.sql

# Set 2 - Bank Balance Guard
mysql -u <user> -p < Day-10/Set2_BankAccountBalanceGuard/triggers.sql
mysql -u <user> -p < Day-10/Set2_BankAccountBalanceGuard/test_evidence.sql

# Set 3 - Hospital Capacity Control
mysql -u <user> -p < Day-10/Set3_HospitalBedCapacityControl/triggers.sql
mysql -u <user> -p < Day-10/Set3_HospitalBedCapacityControl/test_evidence.sql
```
