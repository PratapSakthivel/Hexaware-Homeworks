-- ============================================================================
-- Day 6: Functions, Aggregation, Grouping and Joins - MySQL 8.4 LTS
-- Set 3: Telecom Usage and Billing
-- File: reports.sql
-- Description: Schema, seed data, and 8 telecom usage/billing analytical queries
--              demonstrating aggregation, joins, NULL handling (IFNULL/COALESCE),
--              and ARPU calculations.
-- ============================================================================

DROP DATABASE IF EXISTS telecom_billing_db;
CREATE DATABASE telecom_billing_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE telecom_billing_db;

-- ----------------------------------------------------------------------------
-- 1. SCHEMA DEFINITION
-- ----------------------------------------------------------------------------

CREATE TABLE plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(100) NOT NULL UNIQUE,
    monthly_rental DECIMAL(8, 2) NOT NULL,
    free_call_minutes INT NOT NULL,
    data_limit_gb INT NOT NULL
) ENGINE=InnoDB;

CREATE TABLE subscribers (
    subscriber_id INT AUTO_INCREMENT PRIMARY KEY,
    phone_number VARCHAR(15) NOT NULL UNIQUE,
    subscriber_name VARCHAR(100) NOT NULL,
    circle VARCHAR(50) NOT NULL, -- Telecom Circle / State
    plan_id INT NOT NULL,
    activation_date DATE NOT NULL,
    CONSTRAINT fk_subs_plan FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
) ENGINE=InnoDB;

CREATE TABLE call_records (
    call_id INT AUTO_INCREMENT PRIMARY KEY,
    subscriber_id INT NOT NULL,
    call_date DATE NOT NULL,
    duration_minutes INT NOT NULL,
    data_used_mb INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_calls_sub FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id)
) ENGINE=InnoDB;

CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(25) NOT NULL UNIQUE,
    subscriber_id INT NOT NULL,
    billing_month DATE NOT NULL, -- e.g. 2026-09-01, 2026-10-01
    invoice_amount DECIMAL(10, 2) NOT NULL,
    due_date DATE NOT NULL,
    payment_date DATE NULL, -- NULL indicates unpaid / overdue invoice
    CONSTRAINT fk_invoices_sub FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. SEED DATA POPULATION
-- ----------------------------------------------------------------------------

INSERT INTO plans (plan_id, plan_name, monthly_rental, free_call_minutes, data_limit_gb) VALUES
(1, 'Silver Freedom 299', 299.00, 300, 10),
(2, 'Gold Max 499', 499.00, 1000, 30),
(3, 'Platinum Unlimited 799', 799.00, 3000, 75),
(4, 'Enterprise Infinity 1299', 1299.00, 10000, 200);

-- Subscribers across Circles: Maharashtra, Delhi, Karnataka, Tamil Nadu
INSERT INTO subscribers (subscriber_id, phone_number, subscriber_name, circle, plan_id, activation_date) VALUES
(1, '9820011221', 'Rohan Sharma', 'Maharashtra', 2, '2026-01-10'),
(2, '9820011222', 'Priya Patel', 'Maharashtra', 3, '2026-02-14'),
(3, '9810022331', 'Amit Verma', 'Delhi', 1, '2026-03-01'),
(4, '9810022332', 'Neha Gupta', 'Delhi', 2, '2026-04-15'),
(5, '9845033441', 'Karthik Raja', 'Karnataka', 2, '2026-05-20'),
(6, '9845033442', 'Deepa Nair', 'Karnataka', 3, '2026-06-05'),
(7, '9840044551', 'Suresh Kumar', 'Tamil Nadu', 4, '2026-07-11'),
(8, '9840044552', 'Ananya Iyer', 'Tamil Nadu', 1, '2026-08-01'),
(9, '9840044553', 'Vikram Seth', 'Delhi', 1, '2026-09-01'), -- Subscriber with NO call/data usage!
(10, '9820011229', 'Zoya Akhtar', 'Maharashtra', 2, '2026-09-15'); -- Subscriber with NO call/data usage!

-- Call and Data Records for October 2026
-- Rohan: Plan 2 (30 GB limit = 30720 MB). Used 35,000 MB (Exceeds limit!)
INSERT INTO call_records (subscriber_id, call_date, duration_minutes, data_used_mb) VALUES
(1, '2026-10-02', 120, 12000),
(1, '2026-10-15', 240, 23000), -- Total Rohan = 360 min, 35,000 MB (34.18 GB > 30 GB)
(2, '2026-10-05', 450, 42000), -- Priya: Plan 3 (75 GB). Used 42,000 MB
(3, '2026-10-08', 110, 12500), -- Amit: Plan 1 (10 GB = 10240 MB). Used 12,500 MB (Exceeds limit!)
(4, '2026-10-12', 180, 18000),
(5, '2026-10-14', 310, 25000),
(6, '2026-10-18', 520, 58000), -- Deepa: 520 min, 58,000 MB
(7, '2026-10-20', 890, 110000),-- Suresh: 890 min, 110,000 MB (Top data consumer)
(8, '2026-10-22', 95, 4500);

-- Invoices: Simulated current audit date is 2026-11-13
-- Overdue invoices: Due date was in October and payment_date is NULL (DATEDIFF > 15 days)
INSERT INTO invoices (invoice_id, invoice_number, subscriber_id, billing_month, invoice_amount, due_date, payment_date) VALUES
(1, 'INV-2026-09-001', 1, '2026-09-01', 499.00, '2026-09-20', '2026-09-18'),
(2, 'INV-2026-09-002', 2, '2026-09-01', 799.00, '2026-09-20', '2026-09-19'),
(3, 'INV-2026-10-001', 1, '2026-10-01', 589.50, '2026-10-20', NULL),         -- Unpaid! 24 days overdue (>15)
(4, 'INV-2026-10-002', 2, '2026-10-01', 799.00, '2026-10-20', '2026-10-22'),
(5, 'INV-2026-10-003', 3, '2026-10-01', 345.00, '2026-10-20', NULL),         -- Unpaid! 24 days overdue (>15)
(6, 'INV-2026-10-004', 4, '2026-10-01', 499.00, '2026-10-20', '2026-10-19'),
(7, 'INV-2026-10-005', 5, '2026-10-01', 499.00, '2026-10-20', NULL),         -- Unpaid! 24 days overdue (>15)
(8, 'INV-2026-10-006', 6, '2026-10-01', 799.00, '2026-10-20', '2026-10-20'),
(9, 'INV-2026-10-007', 7, '2026-10-01', 1299.00, '2026-10-20', '2026-10-15'),
(10, 'INV-2026-10-008', 8, '2026-10-01', 299.00, '2026-10-20', '2026-10-25'),
(11, 'INV-2026-10-009', 9, '2026-10-01', 299.00, '2026-10-28', NULL);        -- Unpaid! 16 days overdue (>15)

-- ----------------------------------------------------------------------------
-- 3. THE EIGHT REQUIRED REPORTING QUERIES
-- ----------------------------------------------------------------------------

-- Query 1: Total call minutes per plan
SELECT 
    p.plan_id,
    p.plan_name,
    p.monthly_rental,
    p.free_call_minutes,
    COUNT(DISTINCT s.subscriber_id) AS enrolled_subscribers,
    COALESCE(SUM(cr.duration_minutes), 0) AS total_call_minutes_logged,
    ROUND(COALESCE(AVG(cr.duration_minutes), 0), 1) AS avg_minutes_per_call
FROM plans p
LEFT JOIN subscribers s ON p.plan_id = s.plan_id
LEFT JOIN call_records cr ON s.subscriber_id = cr.subscriber_id
GROUP BY p.plan_id, p.plan_name, p.monthly_rental, p.free_call_minutes
ORDER BY total_call_minutes_logged DESC;

-- Query 2: Subscribers exceeding their plan data limit (HAVING)
SELECT 
    s.subscriber_id,
    s.phone_number,
    s.subscriber_name,
    s.circle,
    p.plan_name,
    p.data_limit_gb AS plan_quota_gb,
    ROUND(SUM(cr.data_used_mb) / 1024.0, 2) AS actual_data_used_gb,
    ROUND((SUM(cr.data_used_mb) / 1024.0) - p.data_limit_gb, 2) AS overage_data_gb
FROM subscribers s
JOIN plans p ON s.plan_id = p.plan_id
JOIN call_records cr ON s.subscriber_id = cr.subscriber_id
GROUP BY s.subscriber_id, s.phone_number, s.subscriber_name, s.circle, p.plan_name, p.data_limit_gb
HAVING (SUM(cr.data_used_mb) / 1024.0) > p.data_limit_gb
ORDER BY overage_data_gb DESC;

-- Query 3: Month-wise billed telecom revenue
SELECT 
    DATE_FORMAT(i.billing_month, '%Y-%m') AS billing_period,
    DATE_FORMAT(i.billing_month, '%M %Y') AS month_title,
    COUNT(i.invoice_id) AS total_invoices_generated,
    CONCAT('INR ', FORMAT(SUM(i.invoice_amount), 2)) AS total_billed_revenue,
    CONCAT('INR ', FORMAT(AVG(i.invoice_amount), 2)) AS average_invoice_value
FROM invoices i
GROUP BY DATE_FORMAT(i.billing_month, '%Y-%m'), DATE_FORMAT(i.billing_month, '%M %Y')
ORDER BY billing_period ASC;

-- Query 4: Invoices overdue by more than 15 days (as of 2026-11-13)
SELECT 
    i.invoice_number,
    s.subscriber_name,
    CONCAT('+91-', s.phone_number) AS contact_number,
    s.circle,
    DATE_FORMAT(i.due_date, '%d-%b-%Y') AS formatted_due_date,
    DATEDIFF('2026-11-13', i.due_date) AS days_overdue,
    CONCAT('INR ', FORMAT(i.invoice_amount, 2)) AS outstanding_balance,
    CASE 
        WHEN DATEDIFF('2026-11-13', i.due_date) > 30 THEN 'CRITICAL - SUSPEND LINE'
        WHEN DATEDIFF('2026-11-13', i.due_date) > 15 THEN 'SEVERELY OVERDUE'
        ELSE 'GRACE PERIOD'
    END AS collection_priority
FROM invoices i
JOIN subscribers s ON i.subscriber_id = s.subscriber_id
WHERE i.payment_date IS NULL 
  AND DATEDIFF('2026-11-13', i.due_date) > 15
ORDER BY days_overdue DESC;

-- Query 5: Subscribers with no usage records (Dormant accounts)
SELECT 
    s.subscriber_id,
    s.subscriber_name,
    s.phone_number,
    s.circle,
    p.plan_name,
    DATE_FORMAT(s.activation_date, '%d-%b-%Y') AS activated_on,
    DATEDIFF('2026-11-13', s.activation_date) AS days_active_zero_usage
FROM subscribers s
JOIN plans p ON s.plan_id = p.plan_id
LEFT JOIN call_records cr ON s.subscriber_id = cr.subscriber_id
WHERE cr.call_id IS NULL
ORDER BY s.activation_date ASC;

-- Query 6: Average Revenue Per User (ARPU) by Circle
SELECT 
    s.circle,
    COUNT(DISTINCT s.subscriber_id) AS total_subscribers,
    ROUND(SUM(i.invoice_amount), 2) AS total_circle_revenue,
    ROUND(SUM(i.invoice_amount) / COUNT(DISTINCT s.subscriber_id), 2) AS arpu_amount
FROM subscribers s
JOIN invoices i ON s.subscriber_id = i.subscriber_id
GROUP BY s.circle
ORDER BY arpu_amount DESC;

-- Query 7: Plan popularity (Subscriber share and revenue contribution)
SELECT 
    p.plan_id,
    p.plan_name,
    COUNT(s.subscriber_id) AS subscriber_count,
    ROUND((COUNT(s.subscriber_id) * 100.0) / (SELECT COUNT(*) FROM subscribers), 1) AS subscriber_share_pct,
    ROUND(SUM(i.invoice_amount), 2) AS total_plan_revenue
FROM plans p
LEFT JOIN subscribers s ON p.plan_id = s.plan_id
LEFT JOIN invoices i ON s.subscriber_id = i.subscriber_id
GROUP BY p.plan_id, p.plan_name
ORDER BY subscriber_count DESC;

-- Query 8: Top-10 data consumers across all networks
SELECT 
    s.subscriber_id,
    s.subscriber_name,
    s.phone_number,
    s.circle,
    p.plan_name,
    ROUND(SUM(cr.data_used_mb) / 1024.0, 2) AS total_data_consumed_gb,
    SUM(cr.duration_minutes) AS total_voice_minutes
FROM subscribers s
JOIN plans p ON s.plan_id = p.plan_id
JOIN call_records cr ON s.subscriber_id = cr.subscriber_id
GROUP BY s.subscriber_id, s.subscriber_name, s.phone_number, s.circle, p.plan_name
ORDER BY total_data_consumed_gb DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- 4. NULL HANDLING IN SUM AND AVG (COALESCE / IFNULL)
-- ----------------------------------------------------------------------------
-- Demonstrates usage on all 10 subscribers (2 have NULL call_records)
SELECT 
    s.subscriber_name,
    COUNT(cr.call_id) AS calls_count,
    SUM(cr.duration_minutes) AS raw_sum_null_if_empty,
    IFNULL(SUM(cr.duration_minutes), 0) AS safe_sum_with_ifnull,
    COALESCE(SUM(cr.duration_minutes), 0) AS safe_sum_with_coalesce
FROM subscribers s
LEFT JOIN call_records cr ON s.subscriber_id = cr.subscriber_id
GROUP BY s.subscriber_id, s.subscriber_name
ORDER BY safe_sum_with_coalesce ASC;

-- ----------------------------------------------------------------------------
-- 5. REVENUE PER PLAN AND CIRCLE MATRIX
-- ----------------------------------------------------------------------------
SELECT 
    p.plan_name,
    s.circle,
    COUNT(DISTINCT s.subscriber_id) AS subscribers_in_circle,
    ROUND(SUM(i.invoice_amount), 2) AS total_revenue
FROM plans p
JOIN subscribers s ON p.plan_id = s.plan_id
JOIN invoices i ON s.subscriber_id = i.subscriber_id
GROUP BY p.plan_name, s.circle
ORDER BY p.plan_name, total_revenue DESC;
