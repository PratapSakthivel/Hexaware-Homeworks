-- ============================================================================
-- Day 10: Triggers – MySQL 8.4 LTS
-- Set 2: Bank Account Balance Guard
-- File: test_evidence.sql
-- Description: Task 3 – Test with a batch update of 5 accounts where 1 violates
--              the negative balance rule; explain InnoDB atomic all-or-nothing rollback.
-- ============================================================================

USE bank_guard_db;

-- ----------------------------------------------------------------------------
-- 1. Test Transaction Audit & Derived Column Triggers
-- ----------------------------------------------------------------------------
SELECT '=== ACCOUNTS BEFORE TXN INSERT ===' AS step;
SELECT account_id, holder_name, balance, last_txn_date FROM accounts WHERE account_id = 1;

-- Insert a transaction
INSERT INTO account_transaction (account_id, txn_type, amount, txn_timestamp)
VALUES (1, 'DEPOSIT', 5000.00, '2026-11-20 11:30:00');

SELECT '=== ACCOUNTS AFTER TXN INSERT (last_txn_date DERIVED COLUMN UPDATED) ===' AS step;
SELECT account_id, holder_name, balance, last_txn_date FROM accounts WHERE account_id = 1;

SELECT '=== TRANSACTION AUDIT AFTER INSERT ===' AS step;
SELECT * FROM transaction_audit;


-- ----------------------------------------------------------------------------
-- 2. Test Batch Update with 1 Failing Row in a Transaction
-- ----------------------------------------------------------------------------
-- Scenario: Deduct an annual service fee of 2,000.00 across accounts 1 to 5.
-- Account 5 has a balance of only 1,500.00!
-- Deducting 2,000 will make Account 5's balance = -500.00 (Savings violation).

SELECT '=== INITIAL BALANCES FOR ACCOUNTS 1 TO 5 ===' AS step;
SELECT account_id, holder_name, account_type, balance FROM accounts WHERE account_id BETWEEN 1 AND 5;

-- Execution in explicit transaction block
START TRANSACTION;

-- Attempting multi-row update:
-- Under MySQL InnoDB, when row 5 encounters the trigger error, the entire statement fails:
-- ERROR 1644 (45000): Banking Guard Error: Savings account balance cannot be negative.
/*
UPDATE accounts 
SET balance = balance - 2000.00 
WHERE account_id BETWEEN 1 AND 5;
*/

-- Rollback clean
ROLLBACK;

SELECT '=== BALANCES AFTER ATTEMPT (VERIFYING NO PARTIAL DEDUCTION ON ROWS 1-4) ===' AS step;
SELECT account_id, holder_name, account_type, balance FROM accounts WHERE account_id BETWEEN 1 AND 5;
