-- ============================================================================
-- Day 10: Triggers – MySQL 8.4 LTS
-- Set 2: Bank Account Balance Guard
-- File: triggers.sql
-- Description: Tasks 1, 2 & 5:
--              Task 1: AFTER INSERT, AFTER UPDATE, AFTER DELETE triggers on
--                      account_transaction that record audit logs.
--              Task 2: BEFORE UPDATE trigger on accounts blocking any update
--                      that would make a savings balance negative.
--              Task 5: Derived column trigger maintaining accounts.last_txn_date.
-- ============================================================================

DROP DATABASE IF EXISTS bank_guard_db;
CREATE DATABASE bank_guard_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bank_guard_db;

-- ----------------------------------------------------------------------------
-- Base Tables
-- ----------------------------------------------------------------------------
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    holder_name VARCHAR(100) NOT NULL,
    account_type ENUM('SAVINGS', 'CURRENT') NOT NULL DEFAULT 'SAVINGS',
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    last_txn_date DATETIME NULL
) ENGINE=InnoDB;

CREATE TABLE account_transaction (
    txn_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    txn_type ENUM('DEPOSIT', 'WITHDRAWAL', 'TRANSFER') NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    txn_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_positive_txn_amt CHECK (amount > 0.00),
    CONSTRAINT fk_tx_acc FOREIGN KEY (account_id) REFERENCES accounts(account_id)
) ENGINE=InnoDB;

CREATE TABLE transaction_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    txn_id INT NOT NULL,
    account_id INT NOT NULL,
    old_amount DECIMAL(15, 2) NULL,
    new_amount DECIMAL(15, 2) NULL,
    audit_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    db_user VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Baseline Accounts Data
-- ----------------------------------------------------------------------------
INSERT INTO accounts (account_id, account_number, holder_name, account_type, balance) VALUES
(1, 'SB-1001', 'Aditi Rao',       'SAVINGS', 25000.00),
(2, 'SB-1002', 'Manish Pandey',   'SAVINGS', 12000.00),
(3, 'SB-1003', 'Kavita Nair',     'SAVINGS',  5000.00),
(4, 'CA-2001', 'Nexus Logistics', 'CURRENT', 100000.00),
(5, 'SB-1004', 'Rohan Sethi',     'SAVINGS',  1500.00);

-- ============================================================================
-- TASK 2: BEFORE UPDATE Trigger - Negative Savings Balance Guard
-- ============================================================================
DELIMITER //

DROP TRIGGER IF EXISTS trg_accounts_before_update //
CREATE TRIGGER trg_accounts_before_update
BEFORE UPDATE ON accounts
FOR EACH ROW
BEGIN
    -- Business rule: Savings accounts cannot be overdrawn below zero
    IF NEW.account_type = 'SAVINGS' AND NEW.balance < 0.00 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Banking Guard Error: Savings account balance cannot be negative.';
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- TASK 1: AFTER INSERT, AFTER UPDATE, AFTER DELETE Triggers on account_transaction
-- TASK 5: Maintain derived column accounts.last_txn_date
-- ============================================================================
DELIMITER //

-- 1. AFTER INSERT Trigger
DROP TRIGGER IF EXISTS trg_txn_after_insert //
CREATE TRIGGER trg_txn_after_insert
AFTER INSERT ON account_transaction
FOR EACH ROW
BEGIN
    -- Record audit log
    INSERT INTO transaction_audit (action_type, txn_id, account_id, old_amount, new_amount, db_user)
    VALUES ('INSERT', NEW.txn_id, NEW.account_id, NULL, NEW.amount, CURRENT_USER());

    -- Derived column maintenance: update last_txn_date
    UPDATE accounts
    SET last_txn_date = NEW.txn_timestamp
    WHERE account_id = NEW.account_id;
END //

-- 2. AFTER UPDATE Trigger
DROP TRIGGER IF EXISTS trg_txn_after_update //
CREATE TRIGGER trg_txn_after_update
AFTER UPDATE ON account_transaction
FOR EACH ROW
BEGIN
    INSERT INTO transaction_audit (action_type, txn_id, account_id, old_amount, new_amount, db_user)
    VALUES ('UPDATE', NEW.txn_id, NEW.account_id, OLD.amount, NEW.amount, CURRENT_USER());

    UPDATE accounts
    SET last_txn_date = NEW.txn_timestamp
    WHERE account_id = NEW.account_id;
END //

-- 3. AFTER DELETE Trigger
DROP TRIGGER IF EXISTS trg_txn_after_delete //
CREATE TRIGGER trg_txn_after_delete
AFTER DELETE ON account_transaction
FOR EACH ROW
BEGIN
    INSERT INTO transaction_audit (action_type, txn_id, account_id, old_amount, new_amount, db_user)
    VALUES ('DELETE', OLD.txn_id, OLD.account_id, OLD.amount, NULL, CURRENT_USER());
END //

DELIMITER ;
