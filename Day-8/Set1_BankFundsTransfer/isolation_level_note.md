# Set 1: Bank Funds Transfer – Isolation Levels & ACID Transaction Technical Note

## Overview
This technical note documents the transaction processing, locking mechanics, savepoint semantics, and concurrency isolation benchmarks implemented in **Set 1 – Bank Funds Transfer** under **MySQL 8.4 LTS (InnoDB Storage Engine)**.

---

## 1. Task Execution & Expected Console Outputs

### Task 1: Full Funds Transfer with Validation
- **Initial Balances:**
  - Account 1 (Aditya Sharma): ₹50,000.00 (`ACTIVE`)
  - Account 2 (Priya Raman): ₹15,000.00 (`ACTIVE`)
- **Action:** Transfer ₹10,000.00 from Account 1 to Account 2.
- **Expected Result:**
```
+----------------------------------------------------+
| task1_transfer_status                              |
+----------------------------------------------------+
| SUCCESS: Funds transferred successfully.           |
+----------------------------------------------------+

=== BALANCES AFTER TASK 1 TRANSFER ===
+------------+----------------+---------------+----------+--------+
| account_id | account_number | customer_name | balance  | status |
+------------+----------------+---------------+----------+--------+
|          1 | ACC-IN-1001    | Aditya Sharma | 40000.00 | ACTIVE |
|          2 | ACC-IN-1002    | Priya Raman   | 25000.00 | ACTIVE |
+------------+----------------+---------------+----------+--------+
```

### Task 2: Deliberate Failure After Debit with Rollback
- **Scenario:** System debits ₹5,000.00 from Account 1. Before Account 2 can be credited, an unexpected network crash or unhandled runtime failure occurs.
- **Inside Transaction (Uncommitted):** Account 1 balance temporarily displays `₹35,000.00`.
- **After `ROLLBACK`:**
```
=== TASK 2: AFTER ROLLBACK (BALANCES MUST BE EXACTLY RESTORED) ===
+------------+---------------+----------+
| account_id | customer_name | balance  |
+------------+---------------+----------+
|          1 | Aditya Sharma | 40000.00 |
|          2 | Priya Raman   | 25000.00 |
+------------+---------------+----------+
```
*Proof of Atomicity:* Account 1 balance is fully restored to ₹40,000.00; no partial debit persists.

### Task 3: Savepoint Partial Rollback (Undoing Fee While Retaining Transfer)
- **Scenario:** Account 1 transfers ₹4,000.00 to Account 3 (Vikram Mehra). An additional priority processing fee of ₹150.00 is charged to Account 1.
- A `SAVEPOINT before_fee_posting` is recorded prior to the fee.
- Due to a fee-waiver override, `ROLLBACK TO SAVEPOINT before_fee_posting` is triggered, followed by `COMMIT`.
- **Expected Balances:**
```
=== TASK 3: FINAL COMMITTED BALANCES (TRANSFER RETAINED, FEE REVERTED) ===
+------------+-------------------+----------+
| account_id | customer_name     | balance  |
+------------+-------------------+----------+
|          1 | Aditya Sharma     | 36000.00 |  <-- (40000 - 4000; fee of 150 was reverted)
|          3 | Vikram Mehra      |  6500.00 |  <-- (2500 + 4000; transfer retained!)
|          5 | Central Fee Pool  | 100000.00|  <-- (Unchanged; 150 never credited)
+------------+-------------------+----------+
```

### Task 4: Statement with CTE, `ROW_NUMBER()`, and `LAG()`
- **Query Output (`statement_cte.sql` for Account 1):**
```
+-------------+---------------------+---------------------------------+------------+----------+-----------------------------+-----------------------------+---------------------+
| txn_seq_num | entry_date          | description                     | entry_type | amount   | opening_balance_before_txn  | closing_balance_after_txn   | ledger_audit_status |
+-------------+---------------------+---------------------------------+------------+----------+-----------------------------+-----------------------------+---------------------+
|           1 | 2026-10-01 09:00:00 | Opening Balance                 | CREDIT     | 50000.00 |                        0.00 |                    50000.00 | VERIFIED_OK         |
|           2 | 2026-10-15 10:00:00 | Salary Credit - Employer Payroll| CREDIT     | 15000.00 |                    50000.00 |                    65000.00 | VERIFIED_OK         |
|           3 | 2026-10-18 14:30:00 | Utility Bill - Electricity Board| DEBIT      |  2500.00 |                    65000.00 |                    62500.00 | VERIFIED_OK         |
|           4 | 2026-10-22 19:15:00 | E-Commerce Merchant Purchase    | DEBIT      |  8200.00 |                    62500.00 |                    54300.00 | VERIFIED_OK         |
|           5 | 2026-10-25 11:20:00 | Cashback Refund - Festive Promo | CREDIT     |  1200.00 |                    54300.00 |                    55500.00 | VERIFIED_OK         |
|           6 | 2026-10-28 17:45:00 | ATM Cash Withdrawal             | DEBIT      |  5500.00 |                    55500.00 |                    50000.00 | VERIFIED_OK         |
+-------------+---------------------+---------------------------------+------------+----------+-----------------------------+-----------------------------+---------------------+
```

---

## 2. Autocommit in MySQL 8.4 InnoDB

By default, MySQL runs with `autocommit = 1` (ON).
- In autocommit mode, every individual SQL statement (`UPDATE`, `INSERT`, `DELETE`) is treated as an independent transaction and committed immediately to disk.
- If a banking operation requires two updates (`UPDATE accounts SET balance = balance - 100 WHERE id = 1` and `UPDATE accounts SET balance = balance + 100 WHERE id = 2`), executing them with `autocommit = 1` outside an explicit `START TRANSACTION` block leaves the system vulnerable to non-atomic execution: if the server halts between the two queries, money is lost from account 1 without reaching account 2.
- Explicit transaction demarcation with `START TRANSACTION;` overrides autocommit until an explicit `COMMIT` or `ROLLBACK` is issued.

---

## 3. Two-Session Experiment: `READ COMMITTED` vs `REPEATABLE READ`

In InnoDB, transaction isolation is governed by Multi-Version Concurrency Control (MVCC) and Undo Logs.

### Experiment Setup
Initial row in Account 1: `balance = 50,000.00`.

| Time | Session A (Reader) | Session B (Writer) |
|:---|:---|:---|
| $T_0$ | Set Isolation Level (e.g. `REPEATABLE READ` or `READ COMMITTED`) | Default Isolation |
| $T_1$ | `START TRANSACTION;` | `START TRANSACTION;` |
| $T_2$ | `SELECT balance FROM accounts WHERE account_id = 1;` $\rightarrow$ **50,000.00** | — |
| $T_3$ | — | `UPDATE accounts SET balance = 55000.00 WHERE account_id = 1;` |
| $T_4$ | `SELECT balance FROM accounts WHERE account_id = 1;` | — |
| $T_5$ | — | `COMMIT;` |
| $T_6$ | `SELECT balance FROM accounts WHERE account_id = 1;` | — |
| $T_7$ | `COMMIT;` | — |

---

### Observed Behaviors

#### Scenario A: Under `READ COMMITTED`
- At $T_4$: Session A sees **50,000.00** (Session B's update is uncommitted; dirty reads are prevented).
- At $T_6$ (after Session B commits): Session A executes the query and reads **55,000.00**!
- **Reason:** In `READ COMMITTED`, InnoDB generates a **fresh read view snapshot** for *every single SELECT statement* within the transaction. Hence, non-repeatable reads can occur.

#### Scenario B: Under `REPEATABLE READ` (MySQL Default)
- At $T_4$: Session A sees **50,000.00** (consistent snapshot).
- At $T_6$ (after Session B commits): Session A executes the query and **still sees 50,000.00**!
- **Reason:** In `REPEATABLE READ`, InnoDB establishes a **single read view snapshot** at the moment the *first read query* is executed in the transaction ($T_2$). All subsequent reads in Session A read from the Undo Log snapshot taken at $T_2$, guaranteeing statement repeatability throughout the entire transaction duration.

---

## 4. Comparison Summary Matrix

| Characteristic | `READ COMMITTED` | `REPEATABLE READ` (Default) |
|:---|:---|:---|
| **Read View Timing** | Created fresh on every individual `SELECT` | Created once on first reading statement |
| **Non-Repeatable Reads** | Possible (values change between queries) | Prevented via MVCC Undo Log snapshots |
| **Phantom Reads** | Possible | Prevented via Next-Key Locking & Gap Locks |
| **Locking Overhead** | Lower (record locks only, gap locks disabled) | Moderate (record locks + gap locks) |
| **Banking Suitability** | High-throughput OLTP with short read transactions | End-of-day reconciliation, audited statements & financial reporting |
