-- ============================================================================
-- Day 7: Joins and Subqueries - MySQL 8.4 LTS
-- Set 3: Retail Returns and Refunds
-- File: advanced_reports.sql
-- Description: Schema, seed data, 10 advanced retail return/refund queries,
--              demonstration of NULL pitfall with NOT IN vs NOT EXISTS,
--              ANY/ALL operators, nested subqueries, and 100x scalability plan.
-- ============================================================================

DROP DATABASE IF EXISTS retail_returns_db;
CREATE DATABASE retail_returns_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE retail_returns_db;

-- ----------------------------------------------------------------------------
-- 1. SCHEMA DEFINITION
-- ----------------------------------------------------------------------------

CREATE TABLE regions (
    region_id INT AUTO_INCREMENT PRIMARY KEY,
    region_name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE stores (
    store_id INT AUTO_INCREMENT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    region_id INT NOT NULL,
    city VARCHAR(60) NOT NULL,
    CONSTRAINT fk_stores_region FOREIGN KEY (region_id) REFERENCES regions(region_id)
) ENGINE=InnoDB;

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    store_id INT NOT NULL,
    manager_id INT NULL, -- Self-referencing FK
    CONSTRAINT fk_emp_store FOREIGN KEY (store_id) REFERENCES stores(store_id),
    CONSTRAINT fk_emp_mgr FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    units_sold INT NOT NULL DEFAULT 100 -- Units sold baseline for return rate
) ENGINE=InnoDB;

CREATE TABLE returns (
    return_id INT AUTO_INCREMENT PRIMARY KEY,
    return_number VARCHAR(25) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    store_id INT NOT NULL,
    return_date DATE NOT NULL,
    return_reason VARCHAR(100) NOT NULL,
    quantity_returned INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_ret_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_ret_prod FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_ret_store FOREIGN KEY (store_id) REFERENCES stores(store_id)
) ENGINE=InnoDB;

CREATE TABLE refunds (
    refund_id INT AUTO_INCREMENT PRIMARY KEY,
    refund_number VARCHAR(25) NOT NULL UNIQUE,
    return_id INT NULL, -- Intentionally NULLable to demonstrate the NOT IN NULL pitfall!
    refund_amount DECIMAL(10, 2) NOT NULL,
    refund_date DATE NOT NULL,
    payment_method VARCHAR(30) NOT NULL, -- ORIGINAL_CARD, STORE_CREDIT, CASH
    CONSTRAINT fk_ref_return FOREIGN KEY (return_id) REFERENCES returns(return_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. SEED DATA POPULATION
-- ----------------------------------------------------------------------------

INSERT INTO regions (region_id, region_name) VALUES
(1, 'Northeast Region'),
(2, 'Midwest Region'),
(3, 'West Coast Region');

INSERT INTO stores (store_id, store_name, region_id, city) VALUES
(1, 'Boston Downtown Store', 1, 'Boston'),
(2, 'New York 5th Ave Flagship', 1, 'New York'),
(3, 'Chicago Michigan Ave Store', 2, 'Chicago'),
(4, 'Indianapolis Central Outlet', 2, 'Indianapolis'),
(5, 'Seattle Pike Place Store', 3, 'Seattle');

INSERT INTO employees (employee_id, employee_name, store_id, manager_id) VALUES
(1, 'Evelyn Reed', 2, NULL),    -- General Retail Manager
(2, 'Mark Spencer', 2, 1),
(3, 'Chloe Bennett', 1, 1),
(4, 'David Kim', 3, 1),
(5, 'Lucas Scott', 3, 4);

INSERT INTO customers (customer_id, customer_name, email) VALUES
(1, 'Alice Walker', 'alice.w@email.com'),
(2, 'Brian O Connor', 'brian.o@email.com'),
(3, 'Claire Dunphy', 'claire.d@email.com'),
(4, 'Daniel Thorne', 'daniel.t@email.com'),
(5, 'Eileen Hughes', 'eileen.h@email.com'); -- Customer with return but NO refund

INSERT INTO products (product_id, product_name, category, unit_price, units_sold) VALUES
(1, 'Noise-Cancelling Earbuds Pro', 'Electronics', 150.00, 100), -- 15 returns (15.0% return rate > 10%)
(2, 'Thermal Cashmere Sweater', 'Apparel', 120.00, 100),       -- 12 returns (12.0% return rate > 10%)
(3, 'Stainless Steel Air Fryer', 'Kitchen', 180.00, 100),      -- 4 returns (4.0% return rate <= 10%)
(4, 'Smart Fitness Tracker Watch', 'Electronics', 90.00, 100); -- 2 returns (2.0% return rate <= 10%)

-- Returns data
INSERT INTO returns (return_id, return_number, customer_id, product_id, store_id, return_date, return_reason, quantity_returned) VALUES
(1, 'RET-1001', 1, 1, 2, '2026-10-02', 'Defective Audio Jack', 15),
(2, 'RET-1002', 2, 2, 2, '2026-10-05', 'Size Too Large', 12),
(3, 'RET-1003', 3, 3, 1, '2026-10-10', 'Heating Element Issue', 4),
(4, 'RET-1004', 4, 4, 3, '2026-10-15', 'Unwanted Gift', 2),
(5, 'RET-1005', 5, 2, 4, '2026-10-20', 'Color Mismatch', 1); -- Eileen's return (NO refund issued yet!)

-- Refunds data (Notice refund_id 4 has return_id = NULL to trigger NOT IN pitfall!)
INSERT INTO refunds (refund_id, refund_number, return_id, refund_amount, refund_date, payment_method) VALUES
(1, 'REF-8001', 1, 2250.00, '2026-10-03', 'ORIGINAL_CARD'), -- Store 2
(2, 'REF-8002', 2, 1440.00, '2026-10-06', 'STORE_CREDIT'),  -- Store 2
(3, 'REF-8003', 3, 720.00, '2026-10-11', 'ORIGINAL_CARD'),   -- Store 1
(4, 'REF-8004', NULL, 150.00, '2026-10-22', 'CASH');         -- Goodwill customer adjustment (NULL return_id!)

-- ----------------------------------------------------------------------------
-- 3. TEN BUSINESS QUESTIONS SOLVED
-- ----------------------------------------------------------------------------

-- Q1: Products with a return rate strictly above 10 percent
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.units_sold,
    COALESCE(SUM(ret.quantity_returned), 0) AS total_units_returned,
    ROUND((COALESCE(SUM(ret.quantity_returned), 0) * 100.0) / p.units_sold, 2) AS return_rate_percentage
FROM products p
LEFT JOIN returns ret ON p.product_id = ret.product_id
GROUP BY p.product_id, p.product_name, p.category, p.units_sold
HAVING (COALESCE(SUM(ret.quantity_returned), 0) * 100.0) / p.units_sold > 10.00
ORDER BY return_rate_percentage DESC;

-- Q2: Customers with returns but NO refund issued (using NOT EXISTS)
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    ret.return_number,
    ret.return_date,
    ret.return_reason
FROM customers c
JOIN returns ret ON c.customer_id = ret.customer_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM refunds ref 
    WHERE ref.return_id = ret.return_id
);

-- Q3: Stores with the highest total refund value
SELECT 
    s.store_id,
    s.store_name,
    s.city,
    r.region_name,
    COALESCE(SUM(ref.refund_amount), 0.00) AS total_refunds_processed
FROM stores s
JOIN regions r ON s.region_id = r.region_id
LEFT JOIN returns ret ON s.store_id = ret.store_id
LEFT JOIN refunds ref ON ret.return_id = ref.return_id
GROUP BY s.store_id, s.store_name, s.city, r.region_name
ORDER BY total_refunds_processed DESC;

-- Q4: Employees and their reporting managers (SELF JOIN)
SELECT 
    e.employee_id,
    e.employee_name,
    s.store_name,
    COALESCE(m.employee_name, 'TOP STORE DIRECTOR') AS reporting_manager
FROM employees e
JOIN stores s ON e.store_id = s.store_id
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY e.employee_id ASC;

-- Q5: Stores whose refund value is greater than ANY other store in the same region
SELECT 
    s.store_id,
    s.store_name,
    s.region_id,
    COALESCE(SUM(ref.refund_amount), 0.00) AS store_refund_total
FROM stores s
LEFT JOIN returns ret ON s.store_id = ret.store_id
LEFT JOIN refunds ref ON ret.return_id = ref.return_id
GROUP BY s.store_id, s.store_name, s.region_id
HAVING store_refund_total > ANY (
    SELECT COALESCE(SUM(ref2.refund_amount), 0.00)
    FROM stores s2
    LEFT JOIN returns ret2 ON s2.store_id = ret2.store_id
    LEFT JOIN refunds ref2 ON ret2.return_id = ref2.return_id
    WHERE s2.region_id = s.region_id AND s2.store_id != s.store_id
    GROUP BY s2.store_id
)
ORDER BY store_refund_total DESC;

-- Q6: Stores whose refund total is greater than ALL stores in Region 2 (ALL operator)
SELECT 
    s.store_id,
    s.store_name,
    COALESCE(SUM(ref.refund_amount), 0.00) AS store_refund_total
FROM stores s
LEFT JOIN returns ret ON s.store_id = ret.store_id
LEFT JOIN refunds ref ON ret.return_id = ref.return_id
GROUP BY s.store_id, s.store_name
HAVING store_refund_total > ALL (
    SELECT COALESCE(SUM(ref2.refund_amount), 0.00)
    FROM stores s2
    LEFT JOIN returns ret2 ON s2.store_id = ret2.store_id
    LEFT JOIN refunds ref2 ON ret2.return_id = ref2.return_id
    WHERE s2.region_id = 2
    GROUP BY s2.store_id
)
ORDER BY store_refund_total DESC;

-- Q7: Customers who have made returns in more than one store (Multi-store returners)
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT ret.store_id) AS distinct_stores_returned_at
FROM customers c
JOIN returns ret ON c.customer_id = ret.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT ret.store_id) > 1;

-- Q8: Products whose return count exceeds the average return count of all products
SELECT 
    p.product_id,
    p.product_name,
    COALESCE(SUM(ret.quantity_returned), 0) AS total_returned_qty,
    ROUND((
        SELECT AVG(prod_returns.qty)
        FROM (
            SELECT COALESCE(SUM(quantity_returned), 0) AS qty
            FROM products p2
            LEFT JOIN returns ret2 ON p2.product_id = ret2.product_id
            GROUP BY p2.product_id
        ) AS prod_returns
    ), 1) AS avg_product_return_qty
FROM products p
LEFT JOIN returns ret ON p.product_id = ret.product_id
GROUP BY p.product_id, p.product_name
HAVING total_returned_qty > (
    SELECT AVG(prod_returns.qty)
    FROM (
        SELECT COALESCE(SUM(quantity_returned), 0) AS qty
        FROM products p2
        LEFT JOIN returns ret2 ON p2.product_id = ret2.product_id
        GROUP BY p2.product_id
    ) AS prod_returns
)
ORDER BY total_returned_qty DESC;

-- Q9: Nested Subquery 1: Second-highest refund amount recorded
SELECT 
    refund_id,
    refund_number,
    refund_amount,
    payment_method
FROM refunds
WHERE refund_amount = (
    SELECT MAX(refund_amount)
    FROM refunds
    WHERE refund_amount < (
        SELECT MAX(refund_amount)
        FROM refunds
    )
);

-- Q10: Nested Subquery 2: Customers whose total refund amount exceeds the average customer refund
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(ref.refund_amount) AS customer_total_refunds
FROM customers c
JOIN returns ret ON c.customer_id = ret.customer_id
JOIN refunds ref ON ret.return_id = ref.return_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(ref.refund_amount) > (
    SELECT AVG(cust_totals.total_amt)
    FROM (
        SELECT SUM(ref2.refund_amount) AS total_amt
        FROM returns ret2
        JOIN refunds ref2 ON ret2.return_id = ref2.return_id
        GROUP BY ret2.customer_id
    ) AS cust_totals
)
ORDER BY customer_total_refunds DESC;

-- ----------------------------------------------------------------------------
-- 4. DEMONSTRATION OF NULL PITFALL WITH NOT IN VS NOT EXISTS
-- ----------------------------------------------------------------------------

-- Pitfall: If refunds table contains ANY row where return_id IS NULL,
-- "return_id NOT IN (SELECT return_id FROM refunds)" evaluates to UNKNOWN/EMPTY SET!
-- Demonstration Query A (FAILS due to NULL):
SELECT return_id, return_number 
FROM returns 
WHERE return_id NOT IN (SELECT return_id FROM refunds);
-- Returns 0 rows (Empty Set) even though Return ID 4 and 5 were never refunded!

-- Safe Fix: NOT EXISTS is NULL-safe and returns the correct un-refunded returns!
-- Demonstration Query B (SUCCEEDS correctly):
SELECT r.return_id, r.return_number, r.return_reason
FROM returns r
WHERE NOT EXISTS (
    SELECT 1 
    FROM refunds ref 
    WHERE ref.return_id = r.return_id
);
