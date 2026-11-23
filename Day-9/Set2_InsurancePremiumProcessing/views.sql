-- ============================================================================
-- Day 9: Views, Stored Procedures, Functions and Cursors – MySQL 8.4 LTS
-- Set 2: Insurance Premium Processing
-- File: views.sql
-- Description: Task 1 – Create view vw_policy_due listing policies due in 30 days
--              with customer details but excluding sensitive columns (e.g. medical history).
-- ============================================================================

DROP DATABASE IF EXISTS insurance_processing_db;
CREATE DATABASE insurance_processing_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE insurance_processing_db;

-- ----------------------------------------------------------------------------
-- Base Tables DDL
-- ----------------------------------------------------------------------------
CREATE TABLE policyholders (
    policyholder_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    aadhaar_ssn_hash VARCHAR(64) NOT NULL, -- Sensitive column (Must be hidden)
    medical_risk_code VARCHAR(30) NOT NULL -- Sensitive clinical diagnosis (Must be hidden)
) ENGINE=InnoDB;

CREATE TABLE insurance_plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(100) NOT NULL,
    plan_code VARCHAR(30) NOT NULL UNIQUE,
    base_annual_rate DECIMAL(12, 2) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE policies (
    policy_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_number VARCHAR(30) NOT NULL UNIQUE,
    policyholder_id INT NOT NULL,
    plan_id INT NOT NULL,
    sum_assured DECIMAL(15, 2) NOT NULL,
    current_premium DECIMAL(12, 2) NOT NULL,
    claim_free_years INT NOT NULL DEFAULT 0,
    policy_status ENUM('ACTIVE', 'DUE', 'LAPSED', 'SURRENDERED') NOT NULL DEFAULT 'ACTIVE',
    renewal_due_date DATE NOT NULL,
    CONSTRAINT fk_pol_holder FOREIGN KEY (policyholder_id) REFERENCES policyholders(policyholder_id),
    CONSTRAINT fk_pol_plan FOREIGN KEY (plan_id) REFERENCES insurance_plans(plan_id)
) ENGINE=InnoDB;

CREATE TABLE claims (
    claim_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_id INT NOT NULL,
    claim_amount DECIMAL(12, 2) NOT NULL,
    claim_status ENUM('SUBMITTED', 'UNDER_REVIEW', 'APPROVED', 'REJECTED') NOT NULL,
    filed_date DATE NOT NULL,
    CONSTRAINT fk_clm_pol FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Baseline Seed Data
-- ----------------------------------------------------------------------------
INSERT INTO policyholders (policyholder_id, full_name, email, phone, aadhaar_ssn_hash, medical_risk_code) VALUES
(1, 'Vikram Singhania', 'vikram.s@example.com', '+91-9876543210', 'HASH-9812A-SECURE', 'DIABETES_STAGE_1'),
(2, 'Ananya Sen',       'ananya.s@example.com', '+91-9876543211', 'HASH-4512B-SECURE', 'CLEAN_HEALTH_0'),
(3, 'Rajesh Khanna',    'rajesh.k@example.com', '+91-9876543212', 'HASH-7819C-SECURE', 'HYPERTENSION_LOW');

INSERT INTO insurance_plans (plan_id, plan_name, plan_code, base_annual_rate) VALUES
(1, 'SecureLife Term Protection', 'PLAN-TERM-01', 12000.00),
(2, 'HealthShield Comprehensive', 'PLAN-HLTH-02', 18500.00);

INSERT INTO policies (policy_id, policy_number, policyholder_id, plan_id, sum_assured, current_premium, claim_free_years, policy_status, renewal_due_date) VALUES
(1, 'POL-IND-2026-001', 1, 1, 10000000.00, 12000.00, 2, 'ACTIVE', DATE_ADD(CURDATE(), INTERVAL 15 DAY)), -- Due in 15 days
(2, 'POL-IND-2026-002', 2, 2,  2500000.00, 18500.00, 4, 'ACTIVE', DATE_ADD(CURDATE(), INTERVAL 25 DAY)), -- Due in 25 days
(3, 'POL-IND-2026-003', 3, 1,  5000000.00, 12000.00, 0, 'ACTIVE', DATE_ADD(CURDATE(), INTERVAL 75 DAY)); -- Due in 75 days (Not due soon)

-- ----------------------------------------------------------------------------
-- TASK 1: View vw_policy_due (Listing policies due within 30 days)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_policy_due AS
SELECT 
    p.policy_id,
    p.policy_number,
    ph.full_name AS policyholder_name,
    ph.email AS contact_email,
    ph.phone AS contact_phone,
    ip.plan_name,
    p.sum_assured,
    p.current_premium,
    p.claim_free_years,
    p.policy_status,
    p.renewal_due_date,
    DATEDIFF(p.renewal_due_date, CURDATE()) AS days_until_due
FROM policies p
JOIN policyholders ph ON p.policyholder_id = ph.policyholder_id
JOIN insurance_plans ip ON p.plan_id = ip.plan_id
WHERE p.policy_status IN ('ACTIVE', 'DUE')
  AND p.renewal_due_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY);

SELECT '=== TEST VIEW: vw_policy_due ===' AS test_header;
SELECT * FROM vw_policy_due;
