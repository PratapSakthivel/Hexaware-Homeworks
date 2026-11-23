# Set 2: Bank Account Balance Guard – MySQL Trigger Limitations Note

## Overview
This document delivers the technical report for **Set 2 – Bank Account Balance Guard** under **MySQL 8.4 LTS**. It details the atomic transaction behavior of batch updates under trigger failures and addresses why MySQL does not support `INSTEAD OF` triggers.

---

## 1. Batch Update Behavior on InnoDB When One Row Violates
In Task 3, a batch deduction of ₹2,000.00 is attempted across 5 accounts. Accounts 1 through 4 have sufficient balance, but Account 5 has ₹1,500.00 (which would yield -₹500.00):
- **Statement Atomicity:** In MySQL InnoDB, a multi-row statement is an atomic sub-transaction.
- When the trigger encounters Account 5 and signals SQLSTATE `45000`, MySQL immediately halts execution.
- Any row modifications already staged in memory/undo logs for Accounts 1 through 4 are **completely reverted**.
- **Result:** No partial updates occur. The entire batch either completely commits or completely rolls back.

---

## 2. Why MySQL Has No `INSTEAD OF` Trigger
In database systems like Oracle and Microsoft SQL Server, `INSTEAD OF` triggers are commonly used to intercept DML statements on complex, non-updatable views (e.g. views with `JOIN`, `GROUP BY`, or aggregate functions) and redirect the updates into underlying base tables.

### Why MySQL Omits `INSTEAD OF` Triggers:
1. **Engine Layering & Architecture:** In MySQL's pluggable storage engine architecture, the SQL parser/optimizer resides in the upper server layer, while table storage and locking reside in InnoDB. `INSTEAD OF` triggers bypass the standard optimizer write execution pipeline, creating architectural complexity across storage engines.
2. **Deterministic Updatable Views:** MySQL resolves view updates by strictly adhering to ANSI SQL updatable view criteria (views with 1-to-1 row mappings to a single base table without aggregates or distinct clauses are updatable natively).

### How MySQL Covers This Need:
- **`BEFORE` Triggers:** Can intercept incoming `NEW.*` values and mutate them in place (e.g., `SET NEW.balance = ...`) before they reach disk.
- **`CHECK` Constraints:** Enforce non-negative invariants deterministically without procedural overhead.
- **Stored Procedures:** The recommended enterprise pattern in MySQL to encapsulate multi-table transactional inserts/updates rather than using non-standard view triggers.
