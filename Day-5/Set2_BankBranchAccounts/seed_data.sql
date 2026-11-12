-- ============================================================================
-- Day 5: Databases, Normalisation and Data Definition - MySQL 8.4 LTS
-- Set 2: Bank Branch Accounts
-- File: seed_data.sql
-- Description: Inserts data, complex filtering with AND, OR, IN, BETWEEN, LIKE,
--              demonstrates DROP vs TRUNCATE vs DELETE, and ALTER TABLE operations.
-- ============================================================================

USE bank_branch_db;

-- ----------------------------------------------------------------------------
-- 1. SEED DATA INSERTION (Minimum 10 rows per table)
-- ----------------------------------------------------------------------------

-- Insert 10 Branches
INSERT INTO branches (branch_id, branch_code, branch_name, city, state) VALUES
(1, 'BR-NY-01', 'Manhattan Flagship Branch', 'New York', 'NY'),
(2, 'BR-IL-02', 'Chicago Loop Financial Center', 'Chicago', 'IL'),
(3, 'BR-CA-03', 'San Francisco Bay Office', 'San Francisco', 'CA'),
(4, 'BR-TX-04', 'Dallas Uptown Branch', 'Dallas', 'TX'),
(5, 'BR-FL-05', 'Miami Brickell Avenue Hub', 'Miami', 'FL'),
(6, 'BR-WA-06', 'Seattle Downtown Branch', 'Seattle', 'WA'),
(7, 'BR-MA-07', 'Boston Back Bay Office', 'Boston', 'MA'),
(8, 'BR-GA-08', 'Atlanta Midtown Branch', 'Atlanta', 'GA'),
(9, 'BR-CO-09', 'Denver Financial District', 'Denver', 'CO'),
(10, 'BR-NC-10', 'Charlotte Queen City Branch', 'Charlotte', 'NC');

-- Insert 10 Relationship Managers
INSERT INTO relationship_managers (rm_id, employee_code, first_name, last_name, email, phone, branch_id) VALUES
(1, 'EMP-101', 'Arthur', 'Pendelton', 'arthur.p@bank.com', '+1-555-2001', 1),
(2, 'EMP-102', 'Beatrice', 'Vance', 'beatrice.v@bank.com', '+1-555-2002', 1),
(3, 'EMP-103', 'Charles', 'Montgomery', 'charles.m@bank.com', '+1-555-2003', 2),
(4, 'EMP-104', 'Diana', 'Prince', 'diana.p@bank.com', '+1-555-2004', 3),
(5, 'EMP-105', 'Edward', 'Nygma', 'edward.n@bank.com', '+1-555-2005', 4),
(6, 'EMP-106', 'Fiona', 'Gallagher', 'fiona.g@bank.com', '+1-555-2006', 5),
(7, 'EMP-107', 'George', 'Bailey', 'george.b@bank.com', '+1-555-2007', 6),
(8, 'EMP-108', 'Helena', 'Bertinelli', 'helena.b@bank.com', '+1-555-2008', 7),
(9, 'EMP-109', 'Ian', 'Malcolm', 'ian.m@bank.com', '+1-555-2009', 8),
(10, 'EMP-110', 'Julia', 'Roberts', 'julia.r@bank.com', '+1-555-2010', 9);

-- Insert 10 Customers
INSERT INTO customers (customer_id, customer_number, first_name, last_name, email, phone, address_line1, city, postal_code) VALUES
(1, 'CUST-8001', 'Liam', 'Neeson', 'liam.n@email.com', '+1-555-3001', '101 Central Park West', 'New York', '10023'),
(2, 'CUST-8002', 'Emma', 'Watson', 'emma.w@email.com', '+1-555-3002', '45 Michigan Ave', 'Chicago', '60601'),
(3, 'CUST-8003', 'Noah', 'Centineo', 'noah.c@email.com', '+1-555-3003', '78 Market St', 'San Francisco', '94103'),
(4, 'CUST-8004', 'Olivia', 'Colman', 'olivia.c@email.com', '+1-555-3004', '204 Elm St', 'Dallas', '75201'),
(5, 'CUST-8005', 'William', 'Dafoe', 'william.d@email.com', '+1-555-3005', '88 Ocean Drive', 'Miami', '33139'),
(6, 'CUST-8006', 'Sophia', 'Loren', 'sophia.l@email.com', '+1-555-3006', '51 Pike Place', 'Seattle', '98101'),
(7, 'CUST-8007', 'James', 'McAvoy', 'james.m@email.com', '+1-555-3007', '12 Beacon St', 'Boston', '02108'),
(8, 'CUST-8008', 'Isabella', 'Rossellini', 'isabella.r@email.com', '+1-555-3008', '99 Peachtree Rd', 'Atlanta', '30309'),
(9, 'CUST-8009', 'Benjamin', 'Bratt', 'benjamin.b@email.com', '+1-555-3009', '30 17th Street', 'Denver', '80202'),
(10, 'CUST-8010', 'Mia', 'Farrow', 'mia.f@email.com', '+1-555-3010', '77 Tryon St', 'Charlotte', '28202');

-- Insert 12 Accounts (Minimum 10 rows, varying types, dates and balances)
INSERT INTO accounts (account_id, account_number, customer_id, branch_id, rm_id, account_type, balance, opened_date, status) VALUES
(1, 'ACC-NYC-10001', 1, 1, 1, 'CHECKING', 145000.50, '2026-08-15', 'ACTIVE'),
(2, 'ACC-NYC-10002', 1, 1, 1, 'SAVINGS', 380250.00, '2026-09-01', 'ACTIVE'),
(3, 'ACC-CHI-10003', 2, 2, 3, 'SAVINGS', 89200.75, '2026-08-20', 'ACTIVE'),
(4, 'ACC-SFO-10004', 3, 3, 4, 'CHECKING', 250000.00, '2026-09-10', 'ACTIVE'),
(5, 'ACC-DAL-10005', 4, 4, 5, 'MONEY_MARKET', 510000.00, '2026-07-28', 'ACTIVE'),
(6, 'ACC-MIA-10006', 5, 5, 6, 'SAVINGS', 45000.25, '2026-06-15', 'ACTIVE'),
(7, 'ACC-SEA-10007', 6, 6, 7, 'FIXED_DEPOSIT', 750000.00, '2026-09-22', 'ACTIVE'),
(8, 'ACC-BOS-10008', 7, 7, 8, 'CHECKING', 18500.00, '2026-08-05', 'ACTIVE'),
(9, 'ACC-ATL-10009', 8, 8, 9, 'SAVINGS', 310500.00, '2026-09-15', 'ACTIVE'),
(10, 'ACC-DEN-10010', 9, 9, 10, 'MONEY_MARKET', 95000.00, '2026-07-10', 'ACTIVE'),
(11, 'ACC-CLT-10011', 10, 10, 10, 'CHECKING', 12500.00, '2026-05-18', 'ACTIVE'),
(12, 'ACC-CLT-10012', 10, 10, 10, 'SAVINGS', 62000.00, '2026-09-28', 'ACTIVE');

-- ----------------------------------------------------------------------------
-- 2. COMPLEX RETRIEVAL: AND, OR, IN, BETWEEN, LIKE
-- ----------------------------------------------------------------------------
-- Query: Find active accounts opened in the last quarter (Q3 2026: 2026-07-01 to 2026-09-30)
-- with balance above $50,000, specific account types ('SAVINGS', 'CHECKING', 'MONEY_MARKET'),
-- and account numbers starting with 'ACC-NYC%' OR 'ACC-SFO%' OR customer last name containing 'W%' or 'N%'.
SELECT 
    a.account_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_full_name,
    c.city AS customer_city,
    b.branch_name,
    CONCAT(rm.first_name, ' ', rm.last_name) AS relationship_manager,
    a.account_type,
    a.balance,
    a.opened_date
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
JOIN branches b ON a.branch_id = b.branch_id
JOIN relationship_managers rm ON a.rm_id = rm.rm_id
WHERE (a.opened_date BETWEEN '2026-07-01' AND '2026-09-30')
  AND a.balance > 50000.00
  AND a.account_type IN ('SAVINGS', 'CHECKING', 'MONEY_MARKET', 'FIXED_DEPOSIT')
  AND (a.account_number LIKE 'ACC-NYC%' OR a.account_number LIKE 'ACC-SFO%' OR a.account_number LIKE 'ACC-CHI%')
ORDER BY a.balance DESC;

-- ----------------------------------------------------------------------------
-- 3. DEMONSTRATION OF DROP, TRUNCATE AND DELETE (AUTO_INCREMENT & ROLLBACK)
-- ----------------------------------------------------------------------------

-- Seed test_audit_log
INSERT INTO test_audit_log (action_name) VALUES ('LOGIN_ATTEMPT'), ('STATEMENT_EXPORT'), ('PASSWORD_RESET');

-- Experiment A: DELETE in a transaction (ROLLBACK supported, AUTO_INCREMENT does not reset)
START TRANSACTION;
DELETE FROM test_audit_log WHERE action_name = 'PASSWORD_RESET';
ROLLBACK; -- Row is restored, transaction undone!

-- Experiment B: TRUNCATE (DDL: implicit commit, cannot rollback, RESETS AUTO_INCREMENT to 1)
TRUNCATE TABLE test_audit_log;
INSERT INTO test_audit_log (action_name) VALUES ('FIRST_POST_TRUNCATE');
-- Output log_id will be 1!

-- Experiment C: DROP TABLE (DDL: Completely removes table definition, metadata, and data from disk)
-- DROP TABLE test_audit_log;

-- ----------------------------------------------------------------------------
-- 4. ALTER TABLE OPERATIONS
-- ----------------------------------------------------------------------------
-- Step 1: Add a 'kyc_status' column with DEFAULT 'PENDING'
ALTER TABLE customers
ADD COLUMN kyc_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
AFTER postal_code;

-- Step 2: Rename test table
ALTER TABLE test_audit_log RENAME TO system_audit_events;

-- Step 3: Add and drop a test constraint
ALTER TABLE accounts
ADD CONSTRAINT chk_test_temporary CHECK (balance < 100000000.00);

ALTER TABLE accounts
DROP CHECK chk_test_temporary;
