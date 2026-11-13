-- ============================================================================
-- Day 7: Joins and Subqueries - MySQL 8.4 LTS
-- Set 2: Bank Loan Portfolio
-- File: advanced_reports.sql
-- Description: Schema, seed data, and 10 advanced banking queries covering
--              loans, repayments, guarantors, branches, correlated subqueries,
--              EXISTS / NOT EXISTS, and nested subqueries.
-- ============================================================================

DROP DATABASE IF EXISTS bank_loans_db;
CREATE DATABASE bank_loans_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE bank_loans_db;

-- ----------------------------------------------------------------------------
-- 1. SCHEMA DEFINITION
-- ----------------------------------------------------------------------------

CREATE TABLE branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(60) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    credit_score INT NOT NULL,
    city VARCHAR(60) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_number VARCHAR(25) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    loan_amount DECIMAL(15, 2) NOT NULL,
    interest_rate DECIMAL(5, 2) NOT NULL,
    tenure_months INT NOT NULL,
    overdue_instalments INT NOT NULL DEFAULT 0,
    disbursed_date DATE NOT NULL,
    loan_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, CLOSED, DEFAULTED
    CONSTRAINT fk_loans_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_loans_branch FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
) ENGINE=InnoDB;

CREATE TABLE repayments (
    repayment_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(15, 2) NOT NULL,
    CONSTRAINT fk_repay_loan FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
) ENGINE=InnoDB;

CREATE TABLE guarantors (
    guarantor_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    customer_id INT NOT NULL, -- Guarantor is also a registered customer
    relationship VARCHAR(50) NOT NULL,
    guaranteed_amount DECIMAL(15, 2) NOT NULL,
    CONSTRAINT fk_guar_loan FOREIGN KEY (loan_id) REFERENCES loans(loan_id),
    CONSTRAINT fk_guar_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. SEED DATA POPULATION
-- ----------------------------------------------------------------------------

INSERT INTO branches (branch_id, branch_name, city) VALUES
(1, 'Manhattan Flagship Branch', 'New York'),
(2, 'Chicago Loop Commercial Branch', 'Chicago'),
(3, 'San Francisco Financial Center', 'San Francisco'),
(4, 'Dallas Uptown Branch', 'Dallas'),
(5, 'Miami Beach Private Branch', 'Miami'); -- Branch with NO loans

INSERT INTO customers (customer_id, customer_name, credit_score, city) VALUES
(1, 'Michael Corleone', 780, 'New York'),
(2, 'Thomas Shelby', 720, 'Chicago'),
(3, 'Walter White', 650, 'Dallas'),
(4, 'Tony Soprano', 590, 'New York'),
(5, 'Bruce Wayne', 820, 'Chicago'),
(6, 'Elena Gilbert', 710, 'San Francisco'),
(7, 'Harvey Specter', 790, 'New York');

-- Current date assumed as 2026-11-13
INSERT INTO loans (loan_id, loan_number, customer_id, branch_id, loan_amount, interest_rate, tenure_months, overdue_instalments, disbursed_date, loan_status) VALUES
(1, 'LN-2026-001', 1, 1, 850000.00, 7.50, 60, 0, '2026-01-15', 'ACTIVE'), -- Corleone
(2, 'LN-2026-002', 1, 2, 450000.00, 8.00, 36, 1, '2026-03-20', 'ACTIVE'), -- Corleone in 2nd branch!
(3, 'LN-2026-003', 2, 2, 600000.00, 8.25, 48, 4, '2026-02-10', 'ACTIVE'), -- Shelby: 4 overdue instalments (>3)
(4, 'LN-2026-004', 3, 4, 320000.00, 9.00, 24, 5, '2026-04-05', 'ACTIVE'), -- White: 5 overdue instalments (>3)
(5, 'LN-2026-005', 4, 1, 1200000.00, 10.50, 84, 6, '2025-11-10', 'ACTIVE'), -- Soprano: Highest loan
(6, 'LN-2026-006', 5, 2, 1500000.00, 6.75, 120, 0, '2026-05-12', 'ACTIVE'), -- Bruce Wayne
(7, 'LN-2026-007', 6, 3, 280000.00, 8.50, 36, 0, '2026-06-18', 'ACTIVE'),
(8, 'LN-2026-008', 7, 1, 400000.00, 7.20, 48, 0, '2026-07-22', 'ACTIVE'),
(9, 'LN-2026-009', 4, 1, 250000.00, 9.50, 24, 0, '2026-08-30', 'ACTIVE');
-- Notice: Branch 5 (Miami) has NO loans.

-- Repayments (60 days prior to 2026-11-13 is ~ 2026-09-14)
-- Loans 3, 4, 5 have NO repayments in the last 60 days!
INSERT INTO repayments (repayment_id, loan_id, payment_date, amount_paid) VALUES
(1, 1, '2026-10-15', 18500.00), -- Loan 1 paid within 60 days
(2, 2, '2026-10-20', 14200.00), -- Loan 2 paid within 60 days
(3, 3, '2026-07-10', 15000.00), -- Loan 3 old payment (>60 days ago)
(4, 4, '2026-06-05', 12000.00), -- Loan 4 old payment (>60 days ago)
(5, 6, '2026-10-28', 21000.00), -- Loan 6 paid within 60 days
(6, 7, '2026-10-18', 9500.00),  -- Loan 7 paid within 60 days
(7, 8, '2026-11-02', 11000.00); -- Loan 8 paid within 60 days

-- Guarantors (Notice Customer 1 Corleone and Customer 2 Shelby also act as Guarantors!)
INSERT INTO guarantors (guarantor_id, loan_id, customer_id, relationship, guaranteed_amount) VALUES
(1, 3, 1, 'Business Partner', 300000.00), -- Corleone guarantees Shelby's loan
(2, 4, 2, 'Associate', 160000.00),        -- Shelby guarantees White's loan
(3, 7, 5, 'Personal Referral', 280000.00);-- Wayne guarantees Gilbert's loan

-- ----------------------------------------------------------------------------
-- 3. TEN BUSINESS QUESTIONS SOLVED
-- ----------------------------------------------------------------------------

-- Q1: Loans overdue by more than three instalments with customer and branch details
SELECT 
    l.loan_number,
    c.customer_name,
    b.branch_name,
    l.loan_amount,
    l.overdue_instalments,
    l.loan_status
FROM loans l
INNER JOIN customers c ON l.customer_id = c.customer_id
INNER JOIN branches b ON l.branch_id = b.branch_id
WHERE l.overdue_instalments > 3
ORDER BY l.overdue_instalments DESC;

-- Q2: Customers with active loans in more than one branch (Multi-branch borrowing)
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT l.branch_id) AS distinct_branch_count,
    GROUP_CONCAT(DISTINCT b.branch_name SEPARATOR ' | ') AS borrowing_branches,
    SUM(l.loan_amount) AS total_borrowed_amount
FROM customers c
INNER JOIN loans l ON c.customer_id = l.customer_id
INNER JOIN branches b ON l.branch_id = b.branch_id
WHERE l.loan_status = 'ACTIVE'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT l.branch_id) > 1;

-- Q3: Guarantors who are also active borrowers in the bank (SELF/DUAL JOIN)
SELECT 
    g.guarantor_id,
    c_guar.customer_name AS guarantor_and_borrower_name,
    g.guaranteed_amount,
    g.relationship,
    l_guaranteed.loan_number AS loan_guaranteed,
    c_borrower.customer_name AS primary_borrower_name,
    l_own.loan_number AS guarantor_own_loan_number,
    l_own.loan_amount AS guarantor_own_loan_amount
FROM guarantors g
INNER JOIN customers c_guar ON g.customer_id = c_guar.customer_id
INNER JOIN loans l_guaranteed ON g.loan_id = l_guaranteed.loan_id
INNER JOIN customers c_borrower ON l_guaranteed.customer_id = c_borrower.customer_id
INNER JOIN loans l_own ON c_guar.customer_id = l_own.customer_id;

-- Q4: Branches with no loans disbursed (LEFT JOIN)
SELECT 
    b.branch_id,
    b.branch_name,
    b.city,
    COUNT(l.loan_id) AS total_loans_count
FROM branches b
LEFT JOIN loans l ON b.branch_id = l.branch_id
GROUP BY b.branch_id, b.branch_name, b.city
HAVING COUNT(l.loan_id) = 0;

-- Q5: Customers whose total loan exposure exceeds their branch average (Correlated Subquery)
SELECT 
    c.customer_id,
    c.customer_name,
    b.branch_name,
    SUM(l.loan_amount) AS customer_total_exposure,
    ROUND((
        SELECT AVG(l2.loan_amount)
        FROM loans l2
        WHERE l2.branch_id = l.branch_id
    ), 2) AS branch_average_loan
FROM customers c
JOIN loans l ON c.customer_id = l.customer_id
JOIN branches b ON l.branch_id = b.branch_id
GROUP BY c.customer_id, c.customer_name, b.branch_name, l.branch_id
HAVING SUM(l.loan_amount) > (
    SELECT AVG(l3.loan_amount)
    FROM loans l3
    WHERE l3.branch_id = l.branch_id
)
ORDER BY customer_total_exposure DESC;

-- Q6: Customers with active loans but NO repayment in the last 60 days (NOT EXISTS)
SELECT 
    c.customer_id,
    c.customer_name,
    l.loan_number,
    l.loan_amount,
    l.disbursed_date
FROM customers c
JOIN loans l ON c.customer_id = l.customer_id
WHERE l.loan_status = 'ACTIVE'
  AND NOT EXISTS (
      SELECT 1 
      FROM repayments r 
      WHERE r.loan_id = l.loan_id 
        AND r.payment_date >= DATE_SUB('2026-11-13', INTERVAL 60 DAY)
  )
ORDER BY l.loan_amount DESC;

-- Q7: Uncorrelated Subquery: Loans with amounts greater than the overall bank average
SELECT 
    l.loan_number,
    c.customer_name,
    b.branch_name,
    l.loan_amount,
    ROUND((SELECT AVG(loan_amount) FROM loans), 2) AS bank_wide_average_loan
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
JOIN branches b ON l.branch_id = b.branch_id
WHERE l.loan_amount > (SELECT AVG(loan_amount) FROM loans)
ORDER BY l.loan_amount DESC;

-- Q8: Customers with verified guarantors using EXISTS
SELECT 
    c.customer_id,
    c.customer_name,
    l.loan_number,
    l.loan_amount
FROM customers c
JOIN loans l ON c.customer_id = l.customer_id
WHERE EXISTS (
    SELECT 1 
    FROM guarantors g 
    WHERE g.loan_id = l.loan_id
);

-- Q9: Nested Subquery: Branches whose highest loan is greater than the average of all branch maximums
SELECT 
    b.branch_id,
    b.branch_name,
    MAX(l.loan_amount) AS branch_max_loan,
    ROUND((
        SELECT AVG(max_branch_loans.max_amt)
        FROM (
            SELECT MAX(loan_amount) AS max_amt
            FROM loans
            GROUP BY branch_id
        ) AS max_branch_loans
    ), 2) AS average_of_branch_maximums
FROM branches b
JOIN loans l ON b.branch_id = l.branch_id
GROUP BY b.branch_id, b.branch_name
HAVING MAX(l.loan_amount) > (
    SELECT AVG(max_branch_loans.max_amt)
    FROM (
        SELECT MAX(loan_amount) AS max_amt
        FROM loans
        GROUP BY branch_id
    ) AS max_branch_loans
)
ORDER BY branch_max_loan DESC;

-- Q10: Total repaid amount per loan compared against original principal
SELECT 
    l.loan_number,
    c.customer_name,
    l.loan_amount AS principal_disbursed,
    COALESCE(SUM(r.amount_paid), 0.00) AS total_repaid_to_date,
    ROUND((COALESCE(SUM(r.amount_paid), 0.00) / l.loan_amount) * 100.0, 2) AS repayment_completion_pct
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
LEFT JOIN repayments r ON l.loan_id = r.loan_id
GROUP BY l.loan_number, c.customer_name, l.loan_amount
ORDER BY repayment_completion_pct DESC;
