-- ============================================================================
-- Day 8: CTEs, Window Functions and Transactions – MySQL 8.4 LTS
-- Set 3: Retail Inventory Reservation
-- File: rank_report.sql
-- Description: Tasks 2, 3 & 4:
--              Task 2: Correlated subquery for products below category average stock.
--              Task 3: CTE ranking products by sales within category (Top 3 via ROW_NUMBER).
--              Task 4: LEAD and LAG showing month-on-month change in sales per product.
-- ============================================================================

USE retail_reservation_db;

-- ----------------------------------------------------------------------------
-- Populate Historical Sales Records Across Multiple Months
-- ----------------------------------------------------------------------------
-- Create Monthly Product Sales History table for MoM Trend Analytics
CREATE TABLE monthly_product_sales (
    sales_record_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    sales_year INT NOT NULL,
    sales_month INT NOT NULL,
    month_name VARCHAR(15) NOT NULL,
    units_sold INT NOT NULL,
    gross_revenue DECIMAL(15, 2) NOT NULL,
    CONSTRAINT uq_prod_month UNIQUE (product_id, sales_year, sales_month),
    CONSTRAINT fk_monthly_prod FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

INSERT INTO monthly_product_sales (product_id, sales_year, sales_month, month_name, units_sold, gross_revenue) VALUES
-- Product 1: UltraBook Pro 14 (Electronics)
(1, 2026, 8,  'August 2026',    12,  900000.00),
(1, 2026, 9,  'September 2026', 18, 1350000.00),
(1, 2026, 10, 'October 2026',   25, 1875000.00),

-- Product 2: Smartphone Ultra 5G (Electronics)
(2, 2026, 8,  'August 2026',    30, 1350000.00),
(2, 2026, 9,  'September 2026', 45, 2025000.00),
(2, 2026, 10, 'October 2026',   40, 1800000.00),

-- Product 3: Pro Tablet 11-inch (Electronics)
(3, 2026, 8,  'August 2026',    15,  480000.00),
(3, 2026, 9,  'September 2026', 14,  448000.00),
(3, 2026, 10, 'October 2026',   22,  704000.00),

-- Product 4: Double Door Refrigerator (Home Appliances)
(4, 2026, 8,  'August 2026',     8,  304000.00),
(4, 2026, 9,  'September 2026', 10,  380000.00),
(4, 2026, 10, 'October 2026',   14,  532000.00),

-- Product 5: Convection Microwave (Home Appliances)
(5, 2026, 8,  'August 2026',    20,  250000.00),
(5, 2026, 9,  'September 2026', 22,  275000.00),
(5, 2026, 10, 'October 2026',   18,  225000.00),

-- Product 6: Robot Vacuum Cleaner (Home Appliances)
(6, 2026, 8,  'August 2026',     5,  120000.00),
(6, 2026, 9,  'September 2026',  7,  168000.00),
(6, 2026, 10, 'October 2026',    9,  216000.00),

-- Product 7: Winter Down Jacket (Apparel)
(7, 2026, 8,  'August 2026',    10,   65000.00),
(7, 2026, 9,  'September 2026', 35,  227500.00),
(7, 2026, 10, 'October 2026',   80,  520000.00),

-- Product 8: Performance Running Shoe (Apparel)
(8, 2026, 8,  'August 2026',    40,  168000.00),
(8, 2026, 9,  'September 2026', 48,  201600.00),
(8, 2026, 10, 'October 2026',   52,  218400.00);


-- ============================================================================
-- TASK 2: Correlated Subquery – Products Below Category Average Stock
-- ============================================================================
SELECT 
    p.product_id,
    p.sku,
    p.product_name,
    c.category_name,
    p.stock_quantity,
    -- Correlated scalar subquery computing average inventory for that specific category
    (
        SELECT ROUND(AVG(p_inner.stock_quantity), 1)
        FROM products p_inner
        WHERE p_inner.category_id = p.category_id
    ) AS category_avg_stock,
    ROUND((
        SELECT AVG(p_inner.stock_quantity)
        FROM products p_inner
        WHERE p_inner.category_id = p.category_id
    ) - p.stock_quantity, 1) AS stock_deficit
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE p.stock_quantity < (
    -- Correlated predicate
    SELECT AVG(p_sub.stock_quantity)
    FROM products p_sub
    WHERE p_sub.category_id = p.category_id
)
ORDER BY c.category_name, stock_deficit DESC;


-- ============================================================================
-- TASK 3: CTE-Based Report – Top 3 Products by Sales per Category (ROW_NUMBER)
-- ============================================================================
WITH CategoryProductSalesCTE AS (
    SELECT 
        c.category_name,
        p.product_id,
        p.sku,
        p.product_name,
        p.price,
        SUM(m.units_sold) AS total_units_sold,
        SUM(m.gross_revenue) AS total_sales_revenue,
        -- Generate rank 1, 2, 3... partitioned by category ordered by total revenue
        ROW_NUMBER() OVER (
            PARTITION BY c.category_id 
            ORDER BY SUM(m.gross_revenue) DESC
        ) AS sales_rank
    FROM products p
    JOIN categories c ON p.category_id = c.category_id
    JOIN monthly_product_sales m ON p.product_id = m.product_id
    GROUP BY c.category_id, c.category_name, p.product_id, p.sku, p.product_name, p.price
)
SELECT 
    category_name,
    sales_rank,
    product_name,
    sku,
    price,
    total_units_sold,
    total_sales_revenue
FROM CategoryProductSalesCTE
WHERE sales_rank <= 3
ORDER BY category_name, sales_rank ASC;


-- ============================================================================
-- TASK 4: Month-on-Month Change in Sales using LEAD() and LAG()
-- ============================================================================
WITH MonthlySalesLeadLagCTE AS (
    SELECT 
        p.product_name,
        c.category_name,
        m.sales_year,
        m.sales_month,
        m.month_name,
        m.units_sold,
        m.gross_revenue,
        -- Previous month's revenue using LAG
        LAG(m.gross_revenue, 1) OVER (
            PARTITION BY m.product_id 
            ORDER BY m.sales_year ASC, m.sales_month ASC
        ) AS prev_month_revenue,
        -- Next month's revenue using LEAD
        LEAD(m.gross_revenue, 1) OVER (
            PARTITION BY m.product_id 
            ORDER BY m.sales_year ASC, m.sales_month ASC
        ) AS next_month_revenue
    FROM monthly_product_sales m
    JOIN products p ON m.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
)
SELECT 
    product_name,
    category_name,
    month_name,
    gross_revenue AS current_month_revenue,
    prev_month_revenue,
    -- Month-on-Month growth amount
    (gross_revenue - prev_month_revenue) AS mom_revenue_growth,
    -- Month-on-Month growth percentage
    ROUND(
        ((gross_revenue - prev_month_revenue) * 100.0) / NULLIF(prev_month_revenue, 0), 
        2
    ) AS mom_growth_pct,
    next_month_revenue AS upcoming_month_projection
FROM MonthlySalesLeadLagCTE
ORDER BY product_name, sales_year ASC, sales_month ASC;
