-- ============================================================================
-- Day 9: Views, Stored Procedures, Functions and Cursors – MySQL 8.4 LTS
-- Set 1: Retail Order Fulfilment
-- File: views.sql
-- Description: Task 1 – Create views:
--              1. vw_order_summary (hiding supplier and cost price columns)
--              2. vw_low_stock (products with stock below reorder threshold)
--              3. Demonstrating updatable view with WITH CHECK OPTION
-- ============================================================================

DROP DATABASE IF EXISTS retail_fulfilment_db;
CREATE DATABASE retail_fulfilment_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE retail_fulfilment_db;

-- ----------------------------------------------------------------------------
-- Base Tables DDL
-- ----------------------------------------------------------------------------
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100) NOT NULL,
    tax_identifier VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    sku VARCHAR(30) NOT NULL UNIQUE,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    cost_price DECIMAL(10, 2) NOT NULL,    -- Sensitive internal financial data
    selling_price DECIMAL(10, 2) NOT NULL, -- Public commercial catalog price
    stock_quantity INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 10,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_positive_selling_price CHECK (selling_price >= cost_price),
    CONSTRAINT fk_prod_supp FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
) ENGINE=InnoDB;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    order_status ENUM('PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ord_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT chk_qty_pos CHECK (quantity > 0),
    CONSTRAINT fk_item_ord FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_item_prod FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Baseline Seed Data
-- ----------------------------------------------------------------------------
INSERT INTO suppliers (supplier_id, supplier_name, contact_email, tax_identifier) VALUES
(1, 'Apex Electronics Ltd', 'contact@apexelectronics.com', 'GSTIN-APEX-01'),
(2, 'Pinnacle Home Appliances', 'sales@pinnaclehome.com', 'GSTIN-PINN-02');

INSERT INTO products (product_id, supplier_id, sku, product_name, category, cost_price, selling_price, stock_quantity, reorder_level, is_active) VALUES
(1, 1, 'ELEC-WCH-01', 'Smartwatch Pro GPS',    'Electronics', 3500.00,  5999.00,  8, 15, TRUE), -- Low stock
(2, 1, 'ELEC-EAR-02', 'True Wireless Earbuds', 'Electronics', 1200.00,  2499.00, 45, 20, TRUE),
(3, 2, 'APPL-BLN-03', 'NutriBlend 500W Mixer', 'Kitchen',     1800.00,  3299.00,  4, 10, TRUE), -- Low stock
(4, 2, 'APPL-AIR-04', 'Digital Air Fryer 4L',  'Kitchen',     4200.00,  7499.00, 18, 10, TRUE);

INSERT INTO customers (customer_id, customer_name, email, city) VALUES
(1, 'Rahul Sharma', 'rahul.s@example.com', 'Mumbai'),
(2, 'Pooja Iyer',   'pooja.i@example.com', 'Bengaluru');

INSERT INTO orders (order_id, order_number, customer_id, order_status, order_date) VALUES
(1, 'ORD-2026-9001', 1, 'DELIVERED', '2026-11-15 10:30:00'),
(2, 'ORD-2026-9002', 2, 'PENDING',   '2026-11-18 14:15:00');

INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1, 5999.00),
(2, 1, 2, 2, 2499.00),
(3, 2, 3, 1, 3299.00);


-- ============================================================================
-- 1. View: vw_order_summary (Hiding Supplier & Cost Price Columns)
-- ============================================================================
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT 
    o.order_id,
    o.order_number,
    o.order_date,
    o.order_status,
    c.customer_name,
    c.email AS customer_email,
    c.city AS customer_city,
    COUNT(oi.item_id) AS total_distinct_items,
    COALESCE(SUM(oi.quantity), 0) AS total_units_ordered,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_number, o.order_date, o.order_status, c.customer_name, c.email, c.city;

SELECT '=== TEST VIEW: vw_order_summary ===' AS view_test;
SELECT * FROM vw_order_summary;


-- ============================================================================
-- 2. View: vw_low_stock with WITH CHECK OPTION (Updatable View)
--    Enforces that stock updates performed through this view cannot violate
--    the WHERE predicate (stock_quantity <= reorder_level).
-- ============================================================================
CREATE OR REPLACE VIEW vw_low_stock AS
SELECT 
    product_id,
    sku,
    product_name,
    category,
    selling_price,
    stock_quantity,
    reorder_level
FROM products
WHERE stock_quantity <= reorder_level
  AND is_active = TRUE
WITH CHECK OPTION;

SELECT '=== INITIAL vw_low_stock CONTENTS ===' AS view_test;
SELECT * FROM vw_low_stock;

-- Test 2A: Valid update through updatable view
UPDATE vw_low_stock 
SET stock_quantity = 5 
WHERE product_id = 1;

SELECT '=== AFTER VALID UPDATE (Product 1 stock set to 5 <= 15) ===' AS view_test;
SELECT product_id, product_name, stock_quantity, reorder_level FROM vw_low_stock WHERE product_id = 1;

-- Test 2B: Proving WITH CHECK OPTION enforcement
-- Attempting to update stock_quantity to 25 (which exceeds reorder_level 15)
-- will be immediately blocked by MySQL with:
-- ERROR 1369 (HY000): CHECK OPTION failed 'retail_fulfilment_db.vw_low_stock'
/*
UPDATE vw_low_stock 
SET stock_quantity = 25 
WHERE product_id = 1;
*/
