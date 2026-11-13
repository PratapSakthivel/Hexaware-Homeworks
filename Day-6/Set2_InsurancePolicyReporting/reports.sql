-- ============================================================================
-- Day 6: Functions, Aggregation, Grouping and Joins - MySQL 8.4 LTS
-- Set 2: Insurance Policy Reporting
-- File: reports.sql
-- Description: Schema, seed data, and 8 analytical queries across policies,
--              customers, premiums, agents, and claims.
-- ============================================================================

DROP DATABASE IF EXISTS insurance_policy_db;
CREATE DATABASE insurance_policy_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE insurance_policy_db;

-- ----------------------------------------------------------------------------
-- 1. SCHEMA DEFINITION
-- ----------------------------------------------------------------------------

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    city VARCHAR(60) NOT NULL,
    email VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE agents (
    agent_id INT AUTO_INCREMENT PRIMARY KEY,
    agent_code VARCHAR(15) NOT NULL UNIQUE,
    agent_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(20) NOT NULL UNIQUE,
    product_name VARCHAR(100) NOT NULL,
    line_of_business VARCHAR(50) NOT NULL -- Motor, Health, Life, Property
) ENGINE=InnoDB;

CREATE TABLE policies (
    policy_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_number VARCHAR(25) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    agent_id INT NOT NULL,
    product_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    annual_premium DECIMAL(12, 2) NOT NULL,
    policy_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT fk_policies_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_policies_agent FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
    CONSTRAINT fk_policies_product FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE TABLE claims (
    claim_id INT AUTO_INCREMENT PRIMARY KEY,
    claim_number VARCHAR(25) NOT NULL UNIQUE,
    policy_id INT NOT NULL,
    incident_date DATE NOT NULL,
    claim_amount DECIMAL(12, 2) NOT NULL,
    settled_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    claim_status VARCHAR(20) NOT NULL DEFAULT 'SUBMITTED',
    CONSTRAINT fk_claims_policy FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. SEED DATA POPULATION
-- ----------------------------------------------------------------------------

INSERT INTO customers (customer_id, customer_name, date_of_birth, city, email) VALUES
(1, 'Marcus Aurelius', '1998-05-15', 'New York', 'marcus.a@email.com'),     -- 28 years (Age Band: 26-35)
(2, 'Eleanor Vance', '2002-11-20', 'Chicago', 'eleanor.v@email.com'),       -- 24 years (Age Band: 18-25)
(3, 'Victor Frankenstein', '1976-08-10', 'Boston', 'victor.f@email.com'),   -- 50 years (Age Band: 46-60)
(4, 'Sarah Connor', '1984-03-25', 'Dallas', 'sarah.c@email.com'),           -- 42 years (Age Band: 36-45)
(5, 'Bruce Wayne', '1980-02-19', 'Chicago', 'bruce.w@email.com'),           -- 46 years (Age Band: 46-60)
(6, 'Diana Prince', '1995-10-14', 'San Francisco', 'diana.p@email.com');    -- 31 years (Age Band: 26-35)

INSERT INTO agents (agent_id, agent_code, agent_name, region) VALUES
(1, 'AGT-001', 'James Gordon', 'Northeast'),
(2, 'AGT-002', 'Harvey Dent', 'Midwest'),
(3, 'AGT-003', 'Rachel Dawes', 'West Coast'),
(4, 'AGT-004', 'Lucius Fox', 'South'),
(5, 'AGT-005', 'Alfred Pennyworth', 'Northeast'),
(6, 'AGT-006', 'Rene Montoya', 'Midwest');

INSERT INTO products (product_id, product_code, product_name, line_of_business) VALUES
(1, 'PRD-MTR-01', 'Comprehensive Motor Shield', 'Motor'),
(2, 'PRD-HLT-02', 'Global Platinum Health Care', 'Health'),
(3, 'PRD-LIF-03', 'Term Life Secure 30Y', 'Life'),
(4, 'PRD-PRP-04', 'Commercial Property Guard', 'Property');

-- Policies: current simulated date is around 2026-11-13
INSERT INTO policies (policy_id, policy_number, customer_id, agent_id, product_id, start_date, end_date, annual_premium, policy_status) VALUES
(101, 'POL-MTR-9821041', 1, 1, 1, '2025-11-20', '2026-11-20', 1200.00, 'ACTIVE'), -- Expiring in 7 days!
(102, 'POL-HLT-5412903', 1, 1, 2, '2025-11-28', '2026-11-28', 2400.00, 'ACTIVE'), -- Expiring in 15 days! (Marcus has >1 policy)
(103, 'POL-MTR-3410982', 2, 2, 1, '2025-12-05', '2026-12-05', 1450.00, 'ACTIVE'), -- Expiring in 22 days!
(104, 'POL-LIF-7823901', 3, 3, 3, '2026-01-15', '2027-01-15', 3800.00, 'ACTIVE'),
(105, 'POL-PRP-1120492', 4, 4, 4, '2026-05-10', '2027-05-10', 8500.00, 'ACTIVE'),
(106, 'POL-MTR-8812904', 5, 5, 1, '2026-08-01', '2027-08-01', 2100.00, 'ACTIVE'),
(107, 'POL-HLT-4491023', 5, 5, 2, '2026-09-12', '2027-09-12', 3600.00, 'ACTIVE'), -- Bruce has >1 policy
(108, 'POL-PRP-6629014', 5, 5, 4, '2026-10-05', '2027-10-05', 12000.00, 'ACTIVE'),-- Bruce has 3rd policy
(109, 'POL-LIF-9912048', 6, 1, 3, '2026-10-15', '2027-10-15', 4200.00, 'ACTIVE'),
(110, 'POL-HLT-3392015', 4, 2, 2, '2026-10-22', '2027-10-22', 2800.00, 'ACTIVE');

-- Claims: Product 1 has $1,200 + $1,450 + $2,100 = $4,750 premium; Claims = $3,500 (Claim ratio = 73.68% > 60%)
INSERT INTO claims (claim_id, claim_number, policy_id, incident_date, claim_amount, settled_amount, claim_status) VALUES
(1, 'CLM-2026-01', 101, '2026-04-10', 3500.00, 3500.00, 'SETTLED'), -- Claim on Policy 101 (Motor)
(2, 'CLM-2026-02', 105, '2026-08-14', 1800.00, 1500.00, 'SETTLED'), -- Claim on Policy 105 (Property)
(3, 'CLM-2026-03', 107, '2026-10-02', 1200.00, 1000.00, 'SETTLED'); -- Claim on Policy 107 (Health)
-- Policies 102, 103, 104, 106, 108, 109, 110 have NO claims!

-- ----------------------------------------------------------------------------
-- 3. THE EIGHT REQUIRED REPORTING QUERIES
-- ----------------------------------------------------------------------------

-- Query 1: Policies expiring in the next 30 days (from 2026-11-13)
SELECT 
    p.policy_id,
    CONCAT(SUBSTRING(p.policy_number, 1, 8), '****') AS masked_policy_number,
    c.customer_name,
    c.city,
    prd.product_name,
    p.end_date AS expiration_date,
    DATEDIFF(p.end_date, '2026-11-13') AS days_until_expiration,
    CONCAT('$', FORMAT(p.annual_premium, 2)) AS annual_premium
FROM policies p
JOIN customers c ON p.customer_id = c.customer_id
JOIN products prd ON p.product_id = prd.product_id
WHERE p.end_date BETWEEN '2026-11-13' AND DATE_ADD('2026-11-13', INTERVAL 30 DAY)
ORDER BY days_until_expiration ASC;

-- Query 2: Total premium written per product
SELECT 
    prd.product_id,
    prd.product_code,
    prd.product_name,
    prd.line_of_business,
    COUNT(p.policy_id) AS total_policies_count,
    ROUND(SUM(p.annual_premium), 2) AS total_premium_written,
    ROUND(AVG(p.annual_premium), 2) AS avg_policy_premium
FROM products prd
JOIN policies p ON prd.product_id = p.product_id
GROUP BY prd.product_id, prd.product_code, prd.product_name, prd.line_of_business
ORDER BY total_premium_written DESC;

-- Query 3: Customers with more than one active policy (HAVING)
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    c.email,
    COUNT(p.policy_id) AS active_policy_count,
    ROUND(SUM(p.annual_premium), 2) AS combined_annual_premium
FROM customers c
JOIN policies p ON c.customer_id = p.customer_id
WHERE p.policy_status = 'ACTIVE'
GROUP BY c.customer_id, c.customer_name, c.city, c.email
HAVING COUNT(p.policy_id) > 1
ORDER BY active_policy_count DESC, combined_annual_premium DESC;

-- Query 4: Claim ratio per product (Total Settled Claims / Total Premium Written)
SELECT 
    prd.product_id,
    prd.product_name,
    prd.line_of_business,
    ROUND(SUM(p.annual_premium), 2) AS total_premium_collected,
    ROUND(COALESCE(SUM(c.settled_amount), 0.00), 2) AS total_claims_paid,
    ROUND((COALESCE(SUM(c.settled_amount), 0.00) / SUM(p.annual_premium)) * 100.0, 2) AS claim_loss_ratio_pct
FROM products prd
JOIN policies p ON prd.product_id = p.product_id
LEFT JOIN claims c ON p.policy_id = c.policy_id
GROUP BY prd.product_id, prd.product_name, prd.line_of_business
ORDER BY claim_loss_ratio_pct DESC;

-- Query 5: Policies without claims (LEFT JOIN where claim is NULL)
SELECT 
    p.policy_id,
    CONCAT(SUBSTRING(p.policy_number, 1, 8), '****') AS masked_policy_no,
    c.customer_name,
    prd.product_name,
    p.start_date,
    p.end_date,
    CONCAT('$', FORMAT(p.annual_premium, 2)) AS safe_premium_earned
FROM policies p
JOIN customers c ON p.customer_id = c.customer_id
JOIN products prd ON p.product_id = prd.product_id
LEFT JOIN claims clm ON p.policy_id = clm.policy_id
WHERE clm.claim_id IS NULL
ORDER BY p.annual_premium DESC;

-- Query 6: Average premium by age band (using CASE and DATEDIFF / TIMESTAMPDIFF)
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, '2026-11-13') BETWEEN 18 AND 25 THEN '18-25 Years (Young Adults)'
        WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, '2026-11-13') BETWEEN 26 AND 35 THEN '26-35 Years (Early Career)'
        WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, '2026-11-13') BETWEEN 36 AND 45 THEN '36-45 Years (Mid-Career)'
        WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, '2026-11-13') BETWEEN 46 AND 60 THEN '46-60 Years (Mature Families)'
        ELSE '60+ Years (Seniors)'
    END AS age_band,
    COUNT(p.policy_id) AS total_policies_in_band,
    ROUND(AVG(p.annual_premium), 2) AS average_premium,
    ROUND(SUM(p.annual_premium), 2) AS total_premium_by_band
FROM customers c
JOIN policies p ON c.customer_id = p.customer_id
GROUP BY age_band
ORDER BY average_premium DESC;

-- Query 7: Monthly new policies written
SELECT 
    DATE_FORMAT(p.start_date, '%Y-%m') AS policy_booking_month,
    DATE_FORMAT(p.start_date, '%M %Y') AS month_name,
    COUNT(p.policy_id) AS new_policies_issued,
    ROUND(SUM(p.annual_premium), 2) AS new_business_premium,
    ROUND(AVG(p.annual_premium), 2) AS avg_deal_size
FROM policies p
GROUP BY DATE_FORMAT(p.start_date, '%Y-%m'), DATE_FORMAT(p.start_date, '%M %Y')
ORDER BY policy_booking_month ASC;

-- Query 8: Top-5 agents by total premium written
SELECT 
    a.agent_id,
    a.agent_code,
    a.agent_name,
    a.region,
    COUNT(p.policy_id) AS total_policies_sold,
    ROUND(SUM(p.annual_premium), 2) AS total_premium_generated
FROM agents a
JOIN policies p ON a.agent_id = p.agent_id
GROUP BY a.agent_id, a.agent_code, a.agent_name, a.region
ORDER BY total_premium_generated DESC
LIMIT 5;

-- ----------------------------------------------------------------------------
-- 4. PRODUCTS WITH CLAIM RATIO > 60% (GROUP BY WITH HAVING)
-- ----------------------------------------------------------------------------
SELECT 
    prd.product_id,
    prd.product_name,
    ROUND(SUM(p.annual_premium), 2) AS total_premium_written,
    ROUND(COALESCE(SUM(c.settled_amount), 0), 2) AS total_claims_paid,
    ROUND((COALESCE(SUM(c.settled_amount), 0) / SUM(p.annual_premium)) * 100.0, 2) AS claim_ratio_percentage
FROM products prd
JOIN policies p ON prd.product_id = p.product_id
LEFT JOIN claims c ON p.policy_id = c.policy_id
GROUP BY prd.product_id, prd.product_name
HAVING (COALESCE(SUM(c.settled_amount), 0) / SUM(p.annual_premium)) * 100.0 > 60.00
ORDER BY claim_ratio_percentage DESC;

-- ----------------------------------------------------------------------------
-- 5. JOIN EXPLANATION & DEMONSTRATION (INNER, LEFT, CROSS)
-- ----------------------------------------------------------------------------
-- Demonstration of CROSS JOIN: Product Portfolio vs Sales Region Matrix
SELECT 
    prd.product_name,
    r.region_name,
    'AVAILABLE FOR SALE' AS distribution_status
FROM products prd
CROSS JOIN (
    SELECT DISTINCT region AS region_name FROM agents
) r
ORDER BY prd.product_name, r.region_name;
