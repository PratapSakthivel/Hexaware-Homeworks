# Day 8: CTEs, Window Functions and Transactions – MySQL 8.4 LTS

## Overview
This directory contains complete solutions, relational database schemas, production seed data, complex SQL transaction scripts, window function analytics, and technical reports for **Day 8 – CTEs, Window Functions and Transactions** of the Hexaware training program.

The assignments cover core enterprise database concepts:
1. **Transactions & ACID Semantics:** `START TRANSACTION`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`, and `ROLLBACK TO SAVEPOINT`.
2. **Pessimistic Concurrency Control:** Row-level locking via `SELECT ... FOR UPDATE`, lock contention, and deadlock avoidance.
3. **Common Table Expressions (CTEs):** Modular multi-step data pipelines for complex reporting.
4. **Window Functions:** Ranking and partition analytics using `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, cumulative aggregations (`SUM() OVER`), and chronological offsets (`LEAD()`, `LAG()`).
5. **Concurrency Isolation Levels:** Empirical comparison between `READ COMMITTED` and `REPEATABLE READ` under the InnoDB storage engine.

---

## Directory Structure

```
Day-8/
├── README.md                                                 # Master overview for Day 8
├── Set1_BankFundsTransfer/
│   ├── transfer.sql                                          # ACID transfer procedure, deliberate failure & savepoint demo
│   ├── statement_cte.sql                                     # Monthly account statement CTE with ROW_NUMBER() and LAG()
│   └── isolation_level_note.md                               # Concurrency note: autocommit & READ COMMITTED vs REPEATABLE READ
├── Set2_AirlineSeatBooking/
│   ├── booking_transaction.sql                               # Seat reservation procedure with SELECT ... FOR UPDATE & concurrency test
│   ├── ranking_report.sql                                    # Fare ranking (RANK vs DENSE_RANK), running revenue CTE & correlated subquery
│   └── locking_and_ranking_note.md                           # Locking behavior explanation & window function comparison
└── Set3_RetailInventoryReservation/
    ├── reservation.sql                                       # Inventory reservation transaction with rollback on insufficient stock
    ├── rank_report.sql                                       # Subqueries below avg, Top-3 sales CTE & MoM growth (LEAD/LAG)
    └── acid_explanation_and_reports.md                       # ACID property breakdown with real scenarios & non-transactional risks
```

---

## Assignment Sets Summary

### Set 1 – Bank Funds Transfer
- **Domain:** Core banking system transferring funds between accounts with atomicity and ledger integrity.
- **Key Concepts:**
  - `START TRANSACTION`, `COMMIT`, and `ROLLBACK` with account balance and status validation.
  - Deliberate failure simulation after sender debit demonstrating zero balance leakage.
  - Partial rollback using `SAVEPOINT` and `ROLLBACK TO SAVEPOINT` to waive fees while committing the transfer.
  - Monthly statement generation using a CTE combined with `ROW_NUMBER()` and `LAG()` to track balance transitions.
  - InnoDB two-session concurrency experiment comparing `READ COMMITTED` and `REPEATABLE READ`.
- **Key Deliverables:**
  - [`Set1_BankFundsTransfer/transfer.sql`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-8/Set1_BankFundsTransfer/transfer.sql)
  - [`Set1_BankFundsTransfer/statement_cte.sql`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-8/Set1_BankFundsTransfer/statement_cte.sql)
  - [`Set1_BankFundsTransfer/isolation_level_note.md`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-8/Set1_BankFundsTransfer/isolation_level_note.md)

---

### Set 2 – Airline Seat Booking
- **Domain:** Airline reservation desk managing seat inventory, pricing tiers, and passenger flight manifests.
- **Key Concepts:**
  - High-concurrency seat reservation transaction using `SELECT ... FOR UPDATE` row locks.
  - Simulation of two simultaneous booking attempts for the same seat, explaining lock acquisition and blocking.
  - Passenger fare ranking comparison using `RANK()` (gap-creating) vs `DENSE_RANK()` (contiguous) under tied fares.
  - Running revenue accumulation per flight using CTE and `SUM() OVER (PARTITION BY ... ORDER BY ...)`.
  - Correlated subquery identifying passengers paying fares above their flight average.
- **Key Deliverables:**
  - [`Set2_AirlineSeatBooking/booking_transaction.sql`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-8/Set2_AirlineSeatBooking/booking_transaction.sql)
  - [`Set2_AirlineSeatBooking/ranking_report.sql`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-8/Set2_AirlineSeatBooking/ranking_report.sql)
  - [`Set2_AirlineSeatBooking/locking_and_ranking_note.md`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-8/Set2_AirlineSeatBooking/locking_and_ranking_note.md)

---

### Set 3 – Retail Inventory Reservation
- **Domain:** E-commerce checkout platform managing warehouse stock and order fulfillment lines.
- **Key Concepts:**
  - Atomic stock reservation procedure decrementing product quantity, creating order headers, and inserting line items.
  - Controlled rollback demonstration verifying that inventory is untouched when requested quantity exceeds available stock.
  - Correlated subquery identifying products with inventory below their category average.
  - CTE ranking top 3 revenue-generating products per category using `ROW_NUMBER()`.
  - Month-on-Month (MoM) sales velocity and growth calculations using `LEAD()` and `LAG()`.
  - In-depth ACID breakdown with concrete retail examples and a proof of failure under non-transactional storage engines (MyISAM).
- **Key Deliverables:**
  - [`Set3_RetailInventoryReservation/reservation.sql`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-8/Set3_RetailInventoryReservation/reservation.sql)
  - [`Set3_RetailInventoryReservation/rank_report.sql`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-8/Set3_RetailInventoryReservation/rank_report.sql)
  - [`Set3_RetailInventoryReservation/acid_explanation_and_reports.md`](file:///c:/Users/ELCOT/Downloads/Hexaware/Hexaware%20Homeworks/Day-8/Set3_RetailInventoryReservation/acid_explanation_and_reports.md)

---

## Execution Instructions (MySQL 8.4 LTS)
To execute any set's SQL script, connect to your MySQL 8.4 instance and run:
```bash
# Set 1 - Bank Funds Transfer
mysql -u <username> -p < Day-8/Set1_BankFundsTransfer/transfer.sql
mysql -u <username> -p < Day-8/Set1_BankFundsTransfer/statement_cte.sql

# Set 2 - Airline Seat Booking
mysql -u <username> -p < Day-8/Set2_AirlineSeatBooking/booking_transaction.sql
mysql -u <username> -p < Day-8/Set2_AirlineSeatBooking/ranking_report.sql

# Set 3 - Retail Inventory Reservation
mysql -u <username> -p < Day-8/Set3_RetailInventoryReservation/reservation.sql
mysql -u <username> -p < Day-8/Set3_RetailInventoryReservation/rank_report.sql
```
