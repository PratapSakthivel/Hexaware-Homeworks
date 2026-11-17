-- ============================================================================
-- Day 8: CTEs, Window Functions and Transactions – MySQL 8.4 LTS
-- Set 1: Bank Funds Transfer
-- File: transfer.sql
-- Description: Core funds transfer implementation with ACID transactions,
--              balance & account validation, deliberate failure & rollback,
--              and savepoint partial rollback for fee-posting.
-- ============================================================================

DROP DATABASE IF EXISTS bank_funds_db;
CREATE DATABASE bank_funds_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bank_funds_db;

-- ----------------------------------------------------------------------------
-- Table DDL
-- ----------------------------------------------------------------------------

-- Accounts Table
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    customer_name VARCHAR(100) NOT NULL,
    account_type ENUM('SAVINGS', 'CHECKING', 'SALARY', 'ESCROW') NOT NULL DEFAULT 'SAVINGS',
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    status ENUM('ACTIVE', 'FROZEN', 'DORMANT', 'CLOSED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_positive_balance CHECK (balance >= 0.00)
) ENGINE=InnoDB;

-- Transaction Audit Ledger
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    reference_number VARCHAR(40) NOT NULL UNIQUE,
    sender_account_id INT NOT NULL,
    receiver_account_id INT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    transaction_type ENUM('TRANSFER', 'FEE', 'REVERSAL', 'DEPOSIT') NOT NULL,
    status ENUM('PENDING', 'SUCCESS', 'FAILED', 'REVERSED') NOT NULL,
    failure_reason VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_txn_sender FOREIGN KEY (sender_account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_txn_receiver FOREIGN KEY (receiver_account_id) REFERENCES accounts(account_id)
) ENGINE=InnoDB;

-- Account Ledger History (Record of every balance movement for statements)
CREATE TABLE account_ledger (
    ledger_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_id INT NULL,
    entry_type ENUM('DEBIT', 'CREDIT') NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    post_balance DECIMAL(15, 2) NOT NULL,
    description VARCHAR(255) NOT NULL,
    entry_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ledger_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_ledger_txn FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
) ENGINE=InnoDB;

-- Bank Fee Configuration & Fee Ledger
CREATE TABLE fee_charges (
    charge_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    account_id INT NOT NULL,
    fee_amount DECIMAL(10, 2) NOT NULL,
    fee_type VARCHAR(50) NOT NULL DEFAULT 'TRANSFER_SERVICE_FEE',
    charged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fee_txn FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT fk_fee_account FOREIGN KEY (account_id) REFERENCES accounts(account_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Baseline Seed Data
-- ----------------------------------------------------------------------------
INSERT INTO accounts (account_id, account_number, customer_name, account_type, balance, status) VALUES
(1, 'ACC-IN-1001', 'Aditya Sharma', 'SAVINGS', 50000.00, 'ACTIVE'),
(2, 'ACC-IN-1002', 'Priya Raman', 'CHECKING', 15000.00, 'ACTIVE'),
(3, 'ACC-IN-1003', 'Vikram Mehra', 'SAVINGS', 2500.00,  'ACTIVE'),
(4, 'ACC-IN-1004', 'Sneha Verma', 'SALARY',   75000.00, 'FROZEN'),
(5, 'ACC-IN-1005', 'Central Fee Pool', 'ESCROW', 100000.00, 'ACTIVE');

-- Baseline ledger entries representing opening balances
INSERT INTO account_ledger (account_id, transaction_id, entry_type, amount, post_balance, description, entry_date) VALUES
(1, NULL, 'CREDIT', 50000.00, 50000.00, 'Opening Balance', '2026-10-01 09:00:00'),
(2, NULL, 'CREDIT', 15000.00, 15000.00, 'Opening Balance', '2026-10-01 09:00:00'),
(3, NULL, 'CREDIT', 2500.00,  2500.00,  'Opening Balance', '2026-10-01 09:00:00'),
(4, NULL, 'CREDIT', 75000.00, 75000.00, 'Opening Balance', '2026-10-01 09:00:00'),
(5, NULL, 'CREDIT', 100000.00, 100000.00, 'Opening Balance', '2026-10-01 09:00:00');

SELECT '=== INITIAL ACCOUNTS STATE ===' AS step;
SELECT account_id, account_number, customer_name, balance, status FROM accounts;


-- ============================================================================
-- TASK 1: Full Funds Transfer with Balance & Account Status Validation
-- Scenario: Transfer 10,000.00 from Account 1 (Aditya) to Account 2 (Priya).
-- ============================================================================
DELIMITER //

DROP PROCEDURE IF EXISTS sp_transfer_funds //
CREATE PROCEDURE sp_transfer_funds(
    IN p_sender_id INT,
    IN p_receiver_id INT,
    IN p_amount DECIMAL(15, 2),
    IN p_ref VARCHAR(40),
    OUT p_result VARCHAR(100)
)
proc_label: BEGIN
    DECLARE v_sender_bal DECIMAL(15, 2);
    DECLARE v_sender_status VARCHAR(20);
    DECLARE v_receiver_status VARCHAR(20);
    DECLARE v_txn_id INT;

    -- Exit handler for any unexpected SQL Exception (e.g., constraint violation)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'FAILED: Transaction rolled back due to an unhandled SQL exception.';
    END;

    -- Basic parameter validation
    IF p_amount <= 0.00 THEN
        SET p_result = 'FAILED: Transfer amount must be strictly positive.';
        LEAVE proc_label;
    END IF;

    IF p_sender_id = p_receiver_id THEN
        SET p_result = 'FAILED: Sender and receiver accounts cannot be identical.';
        LEAVE proc_label;
    END IF;

    -- Begin Transaction
    START TRANSACTION;

    -- Lock both account rows in deterministic ascending ID order to prevent deadlocks
    IF p_sender_id < p_receiver_id THEN
        SELECT balance, status INTO v_sender_bal, v_sender_status 
        FROM accounts WHERE account_id = p_sender_id FOR UPDATE;

        SELECT status INTO v_receiver_status 
        FROM accounts WHERE account_id = p_receiver_id FOR UPDATE;
    ELSE
        SELECT status INTO v_receiver_status 
        FROM accounts WHERE account_id = p_receiver_id FOR UPDATE;

        SELECT balance, status INTO v_sender_bal, v_sender_status 
        FROM accounts WHERE account_id = p_sender_id FOR UPDATE;
    END IF;

    -- Validate Sender existence and status
    IF v_sender_status IS NULL THEN
        ROLLBACK;
        SET p_result = 'FAILED: Sender account does not exist.';
        LEAVE proc_label;
    ELSEIF v_sender_status <> 'ACTIVE' THEN
        ROLLBACK;
        SET p_result = CONCAT('FAILED: Sender account is ', v_sender_status, ', transactions not allowed.');
        LEAVE proc_label;
    END IF;

    -- Validate Receiver existence and status
    IF v_receiver_status IS NULL THEN
        ROLLBACK;
        SET p_result = 'FAILED: Receiver account does not exist.';
        LEAVE proc_label;
    ELSEIF v_receiver_status <> 'ACTIVE' THEN
        ROLLBACK;
        SET p_result = CONCAT('FAILED: Receiver account is ', v_receiver_status, ', transfers blocked.');
        LEAVE proc_label;
    END IF;

    -- Validate Sufficient Balance
    IF v_sender_bal < p_amount THEN
        ROLLBACK;
        SET p_result = CONCAT('FAILED: Insufficient funds. Available: ', v_sender_bal, ', Requested: ', p_amount);
        LEAVE proc_label;
    END IF;

    -- Execute Atomic Debit & Credit
    UPDATE accounts 
    SET balance = balance - p_amount 
    WHERE account_id = p_sender_id;

    UPDATE accounts 
    SET balance = balance + p_amount 
    WHERE account_id = p_receiver_id;

    -- Log transaction in master ledger
    INSERT INTO transactions (reference_number, sender_account_id, receiver_account_id, amount, transaction_type, status)
    VALUES (p_ref, p_sender_id, p_receiver_id, p_amount, 'TRANSFER', 'SUCCESS');
    SET v_txn_id = LAST_INSERT_ID();

    -- Record Debit in Account Ledger
    INSERT INTO account_ledger (account_id, transaction_id, entry_type, amount, post_balance, description, entry_date)
    VALUES (p_sender_id, v_txn_id, 'DEBIT', p_amount, v_sender_bal - p_amount, CONCAT('Transfer to Account ', p_receiver_id), NOW());

    -- Record Credit in Account Ledger
    INSERT INTO account_ledger (account_id, transaction_id, entry_type, amount, post_balance, description, entry_date)
    SELECT p_receiver_id, v_txn_id, 'CREDIT', p_amount, balance, CONCAT('Transfer from Account ', p_sender_id), NOW()
    FROM accounts WHERE account_id = p_receiver_id;

    -- Commit transaction atomically
    COMMIT;
    SET p_result = 'SUCCESS: Funds transferred successfully.';
END //

DELIMITER ;

-- Test Task 1 Execution
SET @res = '';
CALL sp_transfer_funds(1, 2, 10000.00, 'TXN-2026-0001', @res);
SELECT @res AS task1_transfer_status;

-- Validate balances after successful transfer
SELECT '=== BALANCES AFTER TASK 1 TRANSFER ===' AS step;
SELECT account_id, account_number, customer_name, balance, status FROM accounts WHERE account_id IN (1, 2);


-- ============================================================================
-- TASK 2: Demonstrate Deliberate Failure After Debit with Full Rollback
-- Scenario: Attempt to transfer 5,000.00 from Account 1 to Account 2.
--           Debit executes, but an intentional system error occurs (simulating
--           network crash or invalid constraint on receiver).
--           Verify that ROLLBACK restores Account 1's balance completely.
-- ============================================================================

SELECT '=== TASK 2: BEFORE FAILED TRANSFER (ACCOUNT 1 & 2) ===' AS step;
SELECT account_id, customer_name, balance FROM accounts WHERE account_id IN (1, 2);

-- Execute deliberate failure transaction block
START TRANSACTION;

-- Step 1: Debit sender
UPDATE accounts SET balance = balance - 5000.00 WHERE account_id = 1;

-- Show temporary uncommitted balance inside the active transaction
SELECT account_id, customer_name, balance AS dirty_sender_balance_in_txn 
FROM accounts WHERE account_id = 1;

-- Step 2: Simulate deliberate runtime error (e.g., receiver account failure or constraint fault)
-- Here we log deliberate failure condition:
SELECT 'SIMULATING SYSTEM CRASH / INTEGRITY FAILURE BEFORE RECEIVER CREDIT...' AS simulation_notice;

-- Step 3: Trigger ROLLBACK
ROLLBACK;

-- Verify balances after ROLLBACK
SELECT '=== TASK 2: AFTER ROLLBACK (BALANCES MUST BE EXACTLY RESTORED) ===' AS step;
SELECT account_id, customer_name, balance FROM accounts WHERE account_id IN (1, 2);


-- ============================================================================
-- TASK 3: Savepoint Demonstration (Undoing Fee While Retaining Transfer)
-- Scenario: Transfer 4,000.00 from Account 1 to Account 3.
--           Then apply a transfer processing fee of 150.00 against Account 1.
--           A SAVEPOINT `before_fee` is created prior to fee posting.
--           Due to fee-exemption policy, the fee is undone using
--           `ROLLBACK TO SAVEPOINT before_fee`.
--           The overall transaction is then committed: transfer remains, fee is gone.
-- ============================================================================

SELECT '=== TASK 3: BEFORE SAVEPOINT TRANSACTION ===' AS step;
SELECT account_id, customer_name, balance FROM accounts WHERE account_id IN (1, 3, 5);

START TRANSACTION;

-- Step A: Execute primary transfer of 4,000.00
UPDATE accounts SET balance = balance - 4000.00 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 4000.00 WHERE account_id = 3;

INSERT INTO transactions (reference_number, sender_account_id, receiver_account_id, amount, transaction_type, status)
VALUES ('TXN-2026-0003', 1, 3, 4000.00, 'TRANSFER', 'SUCCESS');
SET @t3_id = LAST_INSERT_ID();

INSERT INTO account_ledger (account_id, transaction_id, entry_type, amount, post_balance, description)
SELECT 1, @t3_id, 'DEBIT', 4000.00, balance, 'Transfer to Account 3' FROM accounts WHERE account_id = 1;

INSERT INTO account_ledger (account_id, transaction_id, entry_type, amount, post_balance, description)
SELECT 3, @t3_id, 'CREDIT', 4000.00, balance, 'Transfer from Account 1' FROM accounts WHERE account_id = 3;

-- Step B: Establish SAVEPOINT
SAVEPOINT before_fee_posting;

-- Step C: Post a transaction fee of 150.00 from Account 1 to Central Fee Pool (Account 5)
UPDATE accounts SET balance = balance - 150.00 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 150.00 WHERE account_id = 5;

INSERT INTO fee_charges (transaction_id, account_id, fee_amount, fee_type)
VALUES (@t3_id, 1, 150.00, 'PRIORITY_TRANSFER_FEE');

-- View state with fee applied before rolling back savepoint
SELECT '--- STATE INSIDE TRANSACTION (FEE DEDUCTED) ---' AS sub_step;
SELECT account_id, customer_name, balance FROM accounts WHERE account_id IN (1, 3, 5);

-- Step D: Fee waiver applied! Rollback ONLY to savepoint
ROLLBACK TO SAVEPOINT before_fee_posting;

-- Step E: Commit remaining transaction (the transfer survives!)
COMMIT;

-- Verify final balances after committing with savepoint rollback
SELECT '=== TASK 3: FINAL COMMITTED BALANCES (TRANSFER RETAINED, FEE REVERTED) ===' AS step;
SELECT account_id, customer_name, balance FROM accounts WHERE account_id IN (1, 3, 5);

-- Verify fee table is completely empty (rolled back)
SELECT * FROM fee_charges WHERE transaction_id = @t3_id;
