-- ============================================================================
-- Day 8: CTEs, Window Functions and Transactions – MySQL 8.4 LTS
-- Set 3: Retail Inventory Reservation
-- File: reservation.sql
-- Description: Task 1 – E-Commerce order checkout & stock reservation transaction
--              with inventory decrement, order creation, order lines,
--              and deliberate rollback proof on insufficient stock.
-- ============================================================================

DROP DATABASE IF EXISTS retail_reservation_db;
CREATE DATABASE retail_reservation_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE retail_reservation_db;

-- ----------------------------------------------------------------------------
-- Table DDL
-- ----------------------------------------------------------------------------

-- Product Categories Table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Products Table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    sku VARCHAR(30) NOT NULL UNIQUE,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_non_negative_stock CHECK (stock_quantity >= 0),
    CONSTRAINT fk_prod_cat FOREIGN KEY (category_id) REFERENCES categories(category_id)
) ENGINE=InnoDB;

-- Customers Table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Orders Table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    order_status ENUM('PENDING', 'CONFIRMED', 'CANCELLED', 'RELEASED') NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ord_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;

-- Order Items Table
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    line_total DECIMAL(12, 2) NOT NULL,
    CONSTRAINT chk_positive_qty CHECK (quantity > 0),
    CONSTRAINT fk_item_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_item_prod FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Seed Data
-- ----------------------------------------------------------------------------
INSERT INTO categories (category_id, category_name) VALUES
(1, 'Electronics'),
(2, 'Home Appliances'),
(3, 'Apparel');

INSERT INTO products (product_id, category_id, sku, product_name, price, stock_quantity) VALUES
(1, 1, 'ELEC-LAP-101', 'UltraBook Pro 14',      75000.00, 15),
(2, 1, 'ELEC-PHN-102', 'Smartphone Ultra 5G',    45000.00,  8),
(3, 1, 'ELEC-TAB-103', 'Pro Tablet 11-inch',     32000.00, 20),
(4, 2, 'APPL-REF-201', 'Double Door Refrigerator', 38000.00,  5),
(5, 2, 'APPL-MIC-202', 'Convection Microwave',    12500.00, 12),
(6, 2, 'APPL-VAC-203', 'Robot Vacuum Cleaner',    24000.00,  2), -- Low stock product
(7, 3, 'APPR-JKT-301', 'Winter Down Jacket',       6500.00, 25),
(8, 3, 'APPR-SHS-302', 'Performance Running Shoe', 4200.00, 30);

INSERT INTO customers (customer_id, full_name, email) VALUES
(1, 'Tanvi Saxena',  'tanvi.s@example.com'),
(2, 'Rahul Dravid',  'rahul.d@example.com'),
(3, 'Neha Kulkarni', 'neha.k@example.com');

SELECT '=== INITIAL PRODUCT STOCK LEVELS ===' AS step;
SELECT product_id, sku, product_name, price, stock_quantity FROM products;


-- ============================================================================
-- TASK 1: Atomic Stock Reservation Stored Procedure
--         Reservations decrement stock, create order header, insert order lines.
--         Rolls back cleanly if any line item has insufficient stock.
-- ============================================================================
DELIMITER //

DROP PROCEDURE IF EXISTS sp_reserve_inventory_order //
CREATE PROCEDURE sp_reserve_inventory_order(
    IN p_order_number VARCHAR(30),
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_out_status VARCHAR(150)
)
proc_label: BEGIN
    DECLARE v_available_stock INT;
    DECLARE v_unit_price DECIMAL(10, 2);
    DECLARE v_line_total DECIMAL(12, 2);
    DECLARE v_new_order_id INT;

    -- Generic Exception Handler: Rolls back entire transaction
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_out_status = 'ERROR: Database constraint violation or exception. Entire order reservation rolled back.';
    END;

    IF p_quantity <= 0 THEN
        SET p_out_status = 'REJECTED: Order quantity must be strictly greater than 0.';
        LEAVE proc_label;
    END IF;

    -- Begin Transaction
    START TRANSACTION;

    -- Step 1: Pessimistic Row Lock on Product
    SELECT stock_quantity, price 
    INTO v_available_stock, v_unit_price
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;

    -- Validate product existence
    IF v_unit_price IS NULL THEN
        ROLLBACK;
        SET p_out_status = CONCAT('REJECTED: Product ID ', p_product_id, ' does not exist.');
        LEAVE proc_label;
    END IF;

    -- Step 2: Validate Available Stock
    IF v_available_stock < p_quantity THEN
        ROLLBACK;
        SET p_out_status = CONCAT('FAILED_INSUFFICIENT_STOCK: Requested ', p_quantity, ' units, but only ', v_available_stock, ' available. Transaction aborted.');
        LEAVE proc_label;
    END IF;

    -- Step 3: Decrement Product Stock
    UPDATE products
    SET stock_quantity = stock_quantity - p_quantity
    WHERE product_id = p_product_id;

    -- Step 4: Insert Order Header
    SET v_line_total = v_unit_price * p_quantity;
    INSERT INTO orders (order_number, customer_id, total_amount, order_status)
    VALUES (p_order_number, p_customer_id, v_line_total, 'CONFIRMED');
    SET v_new_order_id = LAST_INSERT_ID();

    -- Step 5: Insert Order Items Line
    INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total)
    VALUES (v_new_order_id, p_product_id, p_quantity, v_unit_price, v_line_total);

    -- Step 6: Atomic Commit
    COMMIT;
    SET p_out_status = CONCAT('SUCCESS: Order ', p_order_number, ' confirmed. Stock reserved: ', p_quantity, ' units. New stock: ', v_available_stock - p_quantity);
END //

DELIMITER ;

-- Test 1A: Successful Order Reservation (1 unit of Robot Vacuum - Prod ID 6, Current Stock 2)
SET @status_msg = '';
CALL sp_reserve_inventory_order('ORD-2026-1001', 1, 6, 1, @status_msg);
SELECT @status_msg AS test_1a_success_result;

-- Verify stock decremented to 1 and order created
SELECT product_id, product_name, stock_quantity FROM products WHERE product_id = 6;
SELECT * FROM orders WHERE order_number = 'ORD-2026-1001';
SELECT * FROM order_items WHERE order_id = 1;


-- ============================================================================
-- Test 1B: Deliberate Insufficient Stock Demonstration (Rollback Proof)
-- Customer 2 requests 5 units of Robot Vacuum, but only 1 remains!
-- ============================================================================
SELECT '=== BEFORE FAILED RESERVATION ATTEMPT ===' AS step;
SELECT product_id, product_name, stock_quantity FROM products WHERE product_id = 6;

SET @fail_msg = '';
CALL sp_reserve_inventory_order('ORD-2026-1002', 2, 6, 5, @fail_msg);
SELECT @fail_msg AS test_1b_failure_result;

-- Verification of Rollback: Stock must remain at exactly 1, and no orphan order created!
SELECT '=== AFTER FAILED ATTEMPT (STOCK MUST REMAIN UNCHANGED AT 1) ===' AS step;
SELECT product_id, product_name, stock_quantity FROM products WHERE product_id = 6;

SELECT '=== CONFIRMING NO ORPHAN ORDER CREATED ===' AS step;
SELECT * FROM orders WHERE order_number = 'ORD-2026-1002';
