-- ============================================================================
-- Day 6: Functions, Aggregation, Grouping and Joins - MySQL 8.4 LTS
-- Set 1: Retail Sales Reporting
-- File: reports.sql
-- Description: Schema setup, sample data population, and 8 comprehensive
--              reporting queries demonstrating joins, aggregation, grouping,
--              functions, NULL behaviour, and WHERE vs HAVING.
-- ============================================================================

DROP DATABASE IF EXISTS retail_sales_db;
CREATE DATABASE retail_sales_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE retail_sales_db;

-- ----------------------------------------------------------------------------
-- 1. SCHEMA DEFINITION
-- ----------------------------------------------------------------------------

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(60) NOT NULL,
    email VARCHAR(100) NOT NULL,
    registered_date DATE NOT NULL
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(60) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    payment_amount DECIMAL(10, 2) NULL, -- Intentionally NULLable to demonstrate NULL behaviour
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    item_discount DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. SEED DATA POPULATION
-- ----------------------------------------------------------------------------

INSERT INTO customers (customer_id, customer_name, city, email, registered_date) VALUES
(1, 'Alice Johnson', 'New York', 'alice.j@email.com', '2026-01-15'),
(2, 'Bob Smith', 'Chicago', 'bob.s@email.com', '2026-02-10'),
(3, 'Charlie Brown', 'New York', 'charlie.b@email.com', '2026-03-05'),
(4, 'Diana Prince', 'San Francisco', 'diana.p@email.com', '2026-03-20'),
(5, 'Evan Wright', 'Chicago', 'evan.w@email.com', '2026-04-12'),
(6, 'Fiona Gallagher', 'Dallas', 'fiona.g@email.com', '2026-05-01'),
(7, 'George Clark', 'Seattle', 'george.c@email.com', '2026-06-18'), -- Customer with NO orders
(8, 'Hannah Abbott', 'Seattle', 'hannah.a@email.com', '2026-07-22'); -- Customer with NO orders

INSERT INTO products (product_id, product_name, category, unit_price) VALUES
(1, 'Pro Wireless Headset', 'Electronics', 150.00),
(2, 'Mechanical RGB Keyboard', 'Electronics', 110.00),
(3, 'Ultra-wide 34-inch Monitor', 'Electronics', 450.00),
(4, 'Ergonomic Desk Chair', 'Furniture', 220.00),
(5, 'Motorized Standing Desk', 'Furniture', 520.00),
(6, 'Organic Fairtrade Coffee 1kg', 'Groceries', 28.00),
(7, 'Matcha Green Tea Powder 250g', 'Groceries', 32.00),
(8, 'Stainless Thermal Flask', 'Home & Kitchen', 35.00);

-- Orders: Alice (4 orders), Bob (3 orders), Charlie (2 orders), Diana (1 order), Evan (1 order), Fiona (1 order unpaid)
INSERT INTO orders (order_id, customer_id, order_date, payment_status, payment_amount) VALUES
(101, 1, '2026-09-02', 'PAID', 750.00),
(102, 1, '2026-09-15', 'PAID', 150.00),
(103, 1, '2026-10-04', 'PAID', 330.00),
(104, 1, '2026-10-20', 'PAID', 450.00), -- Alice has 4 orders
(105, 2, '2026-09-10', 'PAID', 520.00),
(106, 2, '2026-10-12', 'PAID', 220.00),
(107, 2, '2026-10-28', 'PAID', 110.00), -- Bob has 3 orders
(108, 3, '2026-09-18', 'PAID', 60.00),
(109, 3, '2026-10-15', 'PAID', 140.00),
(110, 4, '2026-10-05', 'PAID', 1040.00),
(111, 5, '2026-10-18', 'PAID', 28.00),
(112, 6, '2026-10-29', 'UNPAID', NULL),   -- Order without payment (NULL payment_amount)
(113, 3, '2026-10-30', 'PENDING', NULL);  -- Order without payment (NULL payment_amount)

INSERT INTO order_items (item_id, order_id, product_id, quantity, item_discount) VALUES
(1, 101, 3, 1, 0.00), -- Monitor: 450
(2, 101, 1, 2, 0.00), -- Headset x2: 300
(3, 102, 1, 1, 0.00), -- Headset: 150
(4, 103, 2, 3, 0.00), -- Keyboard x3: 330
(5, 104, 3, 1, 0.00), -- Monitor: 450
(6, 105, 5, 1, 0.00), -- Standing Desk: 520
(7, 106, 4, 1, 0.00), -- Chair: 220
(8, 107, 2, 1, 0.00), -- Keyboard: 110
(9, 108, 7, 2, 4.00), -- Tea x2: 60
(10, 109, 8, 4, 0.00), -- Flask x4: 140
(11, 110, 5, 2, 0.00), -- Standing Desk x2: 1040
(12, 111, 6, 1, 0.00), -- Coffee x1: 28
(13, 112, 4, 1, 0.00), -- Chair x1: 220 (Unpaid)
(14, 113, 8, 2, 0.00); -- Flask x2: 70 (Pending)

-- ----------------------------------------------------------------------------
-- 3. THE EIGHT REQUIRED REPORTING QUERIES
-- ----------------------------------------------------------------------------

-- Query 1: Top-5 products by total gross revenue
SELECT 
    p.product_id,
    UPPER(p.product_name) AS product_name,
    p.category,
    CONCAT('$', FORMAT(p.unit_price, 2)) AS unit_price,
    SUM(oi.quantity) AS total_units_sold,
    CONCAT('$', FORMAT(SUM(oi.quantity * p.unit_price - oi.item_discount), 2)) AS total_gross_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name, p.category, p.unit_price
ORDER BY SUM(oi.quantity * p.unit_price - oi.item_discount) DESC
LIMIT 5;

-- Query 2: Month-wise sales revenue and order counts
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    DATE_FORMAT(o.order_date, '%M %Y') AS month_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_items_sold,
    CONCAT('$', FORMAT(SUM(oi.quantity * p.unit_price - oi.item_discount), 2)) AS monthly_sales_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m'), DATE_FORMAT(o.order_date, '%M %Y')
ORDER BY sales_month ASC;

-- Query 3: Customers with more than three orders (HAVING clause)
SELECT 
    c.customer_id,
    CONCAT(c.customer_name, ' (', c.city, ')') AS customer_profile,
    c.email,
    COUNT(o.order_id) AS order_count,
    ROUND(SUM(oi.quantity * p.unit_price - oi.item_discount), 2) AS lifetime_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name, c.city, c.email
HAVING COUNT(DISTINCT o.order_id) > 3
ORDER BY order_count DESC;

-- Query 4: Average basket value (order value) per city
SELECT 
    c.city,
    COUNT(DISTINCT o.order_id) AS total_city_orders,
    ROUND(SUM(oi.quantity * p.unit_price - oi.item_discount), 2) AS total_city_revenue,
    ROUND(SUM(oi.quantity * p.unit_price - oi.item_discount) / COUNT(DISTINCT o.order_id), 2) AS avg_basket_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.city
ORDER BY avg_basket_value DESC;

-- Query 5: Orders without payment (LEFT JOIN filtering for UNPAID or NULL payment)
SELECT 
    o.order_id,
    DATE_FORMAT(o.order_date, '%d-%b-%Y') AS formatted_order_date,
    DATEDIFF(CURRENT_DATE, o.order_date) AS days_elapsed,
    c.customer_name,
    c.city,
    o.payment_status,
    COALESCE(CONCAT('$', FORMAT(o.payment_amount, 2)), 'NO PAYMENT RECEIVED') AS payment_status_display,
    ROUND(SUM(oi.quantity * p.unit_price - oi.item_discount), 2) AS order_amount_due
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.payment_amount IS NULL OR o.payment_status != 'PAID'
GROUP BY o.order_id, o.order_date, c.customer_name, c.city, o.payment_status, o.payment_amount
ORDER BY o.order_date ASC;

-- Query 6: Customers with no orders (LEFT JOIN where order is NULL)
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    c.email,
    DATE_FORMAT(c.registered_date, '%d-%b-%Y') AS registration_date,
    DATEDIFF(CURRENT_DATE, c.registered_date) AS days_since_registration,
    'INACTIVE / PROSPECT' AS account_status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id ASC;

-- Query 7: Product-category revenue share percentage
SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) AS distinct_products_count,
    SUM(oi.quantity) AS total_quantity_sold,
    ROUND(SUM(oi.quantity * p.unit_price - oi.item_discount), 2) AS category_revenue,
    ROUND(
        (SUM(oi.quantity * p.unit_price - oi.item_discount) * 100.0) / 
        (SELECT SUM(oi2.quantity * p2.unit_price - oi2.item_discount) 
         FROM order_items oi2 JOIN products p2 ON oi2.product_id = p2.product_id), 
        2
    ) AS revenue_percentage_share
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- Query 8: The day with the highest total sales
SELECT 
    o.order_date,
    DATE_FORMAT(o.order_date, '%W, %d %M %Y') AS full_date_description,
    COUNT(DISTINCT o.order_id) AS orders_count,
    SUM(oi.quantity) AS total_items_sold,
    ROUND(SUM(oi.quantity * p.unit_price - oi.item_discount), 2) AS peak_day_sales_amount
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_date
ORDER BY peak_day_sales_amount DESC
LIMIT 1;

-- ----------------------------------------------------------------------------
-- 4. NULL BEHAVIOUR DEMONSTRATION: COUNT(*), COUNT(col), SUM, AVG
-- ----------------------------------------------------------------------------
-- Note: orders table has 13 total rows, 11 with non-null payment_amount, 2 with NULL.
SELECT 
    COUNT(*) AS total_rows_count_star,                     -- Counts every row regardless of NULL (13)
    COUNT(payment_amount) AS count_payment_column,          -- Ignores NULL values, counts only non-null (11)
    SUM(payment_amount) AS total_paid_sum,                  -- Ignores NULLs, sums 11 paid amounts ($3,718.00)
    ROUND(AVG(payment_amount), 2) AS default_avg_ignores_null, -- Sum divided by non-null count: 3718 / 11 = $338.00
    ROUND(AVG(COALESCE(payment_amount, 0)), 2) AS true_avg_treating_null_zero -- Sum divided by all 13 rows: 3718 / 13 = $286.00
FROM orders;

-- ----------------------------------------------------------------------------
-- 5. WHERE VS HAVING DEMONSTRATION
-- ----------------------------------------------------------------------------
-- WHERE filters individual rows BEFORE grouping.
-- HAVING filters aggregated groups AFTER GROUP BY execution.
SELECT 
    c.city,
    COUNT(DISTINCT o.order_id) AS orders_in_city,
    ROUND(SUM(oi.quantity * p.unit_price), 2) AS city_gross_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_date >= '2026-09-01'              -- Row-level filter BEFORE grouping
GROUP BY c.city
HAVING SUM(oi.quantity * p.unit_price) > 500.00 -- Aggregate filter AFTER grouping
ORDER BY city_gross_sales DESC;
