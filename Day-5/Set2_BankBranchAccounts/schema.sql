-- ============================================================================
-- Day 5: Databases, Normalisation and Data Definition - MySQL 8.4 LTS
-- Set 2: Bank Branch Accounts
-- File: schema.sql
-- ============================================================================

DROP DATABASE IF EXISTS bank_branch_db;
CREATE DATABASE bank_branch_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE bank_branch_db;

-- 1. Branches Table
CREATE TABLE branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_code VARCHAR(10) NOT NULL,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(60) NOT NULL,
    state VARCHAR(60) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_branch_code UNIQUE (branch_code)
) ENGINE=InnoDB;

-- 2. Relationship Managers Table
CREATE TABLE relationship_managers (
    rm_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_code VARCHAR(15) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    branch_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_rm_employee_code UNIQUE (employee_code),
    CONSTRAINT uq_rm_email UNIQUE (email),
    CONSTRAINT fk_rm_branch
        FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 3. Customers Table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_number VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address_line1 VARCHAR(150) NOT NULL,
    city VARCHAR(60) NOT NULL,
    postal_code VARCHAR(15) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_customer_number UNIQUE (customer_number),
    CONSTRAINT uq_customer_email UNIQUE (email)
) ENGINE=InnoDB;

-- 4. Accounts Table
-- Justification of DECIMAL(15,2): Exact fixed-point numeric representation avoids
-- IEEE 754 floating-point rounding errors crucial for financial balances.
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    account_number VARCHAR(20) NOT NULL,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    rm_id INT NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    opened_date DATE NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_account_number UNIQUE (account_number),
    CONSTRAINT chk_account_type CHECK (account_type IN ('SAVINGS', 'CHECKING', 'MONEY_MARKET', 'FIXED_DEPOSIT', 'LOAN')),
    CONSTRAINT chk_account_balance CHECK (balance >= 0.00),
    CONSTRAINT fk_accounts_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_accounts_branch
        FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_accounts_rm
        FOREIGN KEY (rm_id) REFERENCES relationship_managers(rm_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 5. Test Table for DROP vs TRUNCATE vs DELETE demonstration
CREATE TABLE test_audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action_name VARCHAR(50) NOT NULL,
    log_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
