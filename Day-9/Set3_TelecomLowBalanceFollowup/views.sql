-- ============================================================================
-- Day 9: Views, Stored Procedures, Functions and Cursors – MySQL 8.4 LTS
-- Set 3: Telecom Low-Balance Follow-up
-- File: views.sql
-- Description: Task 1 – Create views:
--              1. vw_prepaid_subscribers (Hiding postpaid users & sensitive PII)
--              2. vw_recharge_summary (Aggregating historical top-ups per user)
-- ============================================================================

DROP DATABASE IF EXISTS telecom_followup_db;
CREATE DATABASE telecom_followup_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE telecom_followup_db;

-- ----------------------------------------------------------------------------
-- Base Tables DDL
-- ----------------------------------------------------------------------------
CREATE TABLE subscribers (
    subscriber_id INT AUTO_INCREMENT PRIMARY KEY,
    mobile_number VARCHAR(15) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    id_proof_number VARCHAR(50) NOT NULL, -- Sensitive Government ID / PII
    plan_type ENUM('PREPAID', 'POSTPAID') NOT NULL DEFAULT 'PREPAID',
    current_balance DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    validity_expiry_date DATE NOT NULL,
    telecom_circle VARCHAR(30) NOT NULL,
    status ENUM('ACTIVE', 'SUSPENDED', 'DEACTIVATED') NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB;

CREATE TABLE recharge_plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    talktime_amount DECIMAL(10, 2) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    validity_days INT NOT NULL,
    data_benefit_gb INT NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE recharge_history (
    recharge_id INT AUTO_INCREMENT PRIMARY KEY,
    subscriber_id INT NOT NULL,
    plan_id INT NOT NULL,
    amount_paid DECIMAL(10, 2) NOT NULL,
    talktime_credited DECIMAL(10, 2) NOT NULL,
    recharge_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_mode ENUM('UPI', 'CREDIT_CARD', 'NET_BANKING', 'VOUCHER') NOT NULL,
    CONSTRAINT fk_rec_sub FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id),
    CONSTRAINT fk_rec_plan FOREIGN KEY (plan_id) REFERENCES recharge_plans(plan_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Baseline Seed Data
-- ----------------------------------------------------------------------------
INSERT INTO recharge_plans (plan_id, plan_name, talktime_amount, price, validity_days, data_benefit_gb) VALUES
(1, 'Hero Unlimited 28D', 100.00, 299.00, 28, 42),
(2, 'Annual Freedom 365D', 1500.00, 2999.00, 365, 730),
(3, 'Emergency Top-Up',    45.00,  50.00,  0,  0);

INSERT INTO subscribers (subscriber_id, mobile_number, full_name, id_proof_number, plan_type, current_balance, validity_expiry_date, telecom_circle, status) VALUES
(1, '9820011223', 'Aman Verma',     'AADHAAR-9901-XXXX', 'PREPAID',  24.50, DATE_ADD(CURDATE(), INTERVAL 4 DAY),   'Mumbai', 'ACTIVE'), -- Low balance < 50
(2, '9820011224', 'Sunita Rao',     'AADHAAR-9902-XXXX', 'PREPAID', 150.00, DATE_ADD(CURDATE(), INTERVAL 45 DAY),  'Delhi',  'ACTIVE'),
(3, '9820011225', 'Karthik Pillai', 'AADHAAR-9903-XXXX', 'PREPAID',  12.00, DATE_ADD(CURDATE(), INTERVAL 2 DAY),   'Chennai', 'ACTIVE'), -- Low balance < 50
(4, '9820011226', 'Megha Kapoor',   'AADHAAR-9904-XXXX', 'POSTPAID', 850.00, DATE_ADD(CURDATE(), INTERVAL 120 DAY), 'Mumbai', 'ACTIVE'); -- Postpaid (Must be excluded)

INSERT INTO recharge_history (subscriber_id, plan_id, amount_paid, talktime_credited, recharge_date, payment_mode) VALUES
(1, 1, 299.00, 100.00, DATE_SUB(NOW(), INTERVAL 24 DAY), 'UPI'),
(2, 1, 299.00, 100.00, DATE_SUB(NOW(), INTERVAL 10 DAY), 'NET_BANKING'),
(3, 3,  50.00,  45.00, DATE_SUB(NOW(), INTERVAL 15 DAY), 'UPI');


-- ============================================================================
-- 1. View: vw_prepaid_subscribers (Hides Postpaid & Sensitive ID Proof)
-- ============================================================================
CREATE OR REPLACE VIEW vw_prepaid_subscribers AS
SELECT 
    subscriber_id,
    mobile_number,
    full_name,
    current_balance,
    validity_expiry_date,
    telecom_circle,
    status
FROM subscribers
WHERE plan_type = 'PREPAID'
  AND status = 'ACTIVE';

SELECT '=== TEST VIEW: vw_prepaid_subscribers ===' AS test_header;
SELECT * FROM vw_prepaid_subscribers;


-- ============================================================================
-- 2. View: vw_recharge_summary (Aggregating historical top-ups)
-- ============================================================================
CREATE OR REPLACE VIEW vw_recharge_summary AS
SELECT 
    s.subscriber_id,
    s.mobile_number,
    s.full_name,
    s.current_balance,
    COUNT(rh.recharge_id) AS total_recharge_count,
    COALESCE(SUM(rh.amount_paid), 0.00) AS total_amount_spent,
    COALESCE(SUM(rh.talktime_credited), 0.00) AS total_talktime_credited,
    MAX(rh.recharge_date) AS last_recharge_date
FROM subscribers s
LEFT JOIN recharge_history rh ON s.subscriber_id = rh.subscriber_id
WHERE s.plan_type = 'PREPAID'
GROUP BY s.subscriber_id, s.mobile_number, s.full_name, s.current_balance;

SELECT '=== TEST VIEW: vw_recharge_summary ===' AS test_header;
SELECT * FROM vw_recharge_summary;
