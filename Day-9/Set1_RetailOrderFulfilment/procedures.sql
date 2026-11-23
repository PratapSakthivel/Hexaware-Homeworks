-- ============================================================================
-- Day 9: Views, Stored Procedures, Functions and Cursors – MySQL 8.4 LTS
-- Set 1: Retail Order Fulfilment
-- File: procedures.sql
-- Description: Tasks 2, 3 & 5:
--              Task 2: sp_place_order with IN/OUT parameters, stock validation,
--                      DECLARE ... HANDLER FOR SQLEXCEPTION with rollback.
--              Task 3: Stored function fn_order_total_with_tax and comparison.
--              Task 5: Business validation error with SIGNAL SQLSTATE '45000'.
-- ============================================================================

USE retail_fulfilment_db;

-- ============================================================================
-- TASK 2 & 5: sp_place_order with Validation, Transaction & SIGNAL Error
-- ============================================================================
DELIMITER //

DROP PROCEDURE IF EXISTS sp_place_order //
CREATE PROCEDURE sp_place_order(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_order_number VARCHAR(30)
)
proc_label: BEGIN
    DECLARE v_available_stock INT;
    DECLARE v_unit_price DECIMAL(10, 2);
    DECLARE v_new_order_id INT;
    DECLARE v_gen_order_num VARCHAR(30);

    -- Exit Handler: Automatically rolls back transaction on any unhandled SQL error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_order_number = NULL;
        RESIGNAL;
    END;

    -- Validate input parameters
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validation Error: Order quantity must be strictly greater than zero.';
    END IF;

    -- Validate customer existence
    IF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = p_customer_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validation Error: Customer ID not found in system.';
    END IF;

    -- Start Atomic Transaction
    START TRANSACTION;

    -- Step 1: Check available stock with exclusive row lock
    SELECT stock_quantity, selling_price 
    INTO v_available_stock, v_unit_price
    FROM products 
    WHERE product_id = p_product_id AND is_active = TRUE
    FOR UPDATE;

    IF v_unit_price IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validation Error: Product does not exist or is marked inactive.';
    END IF;

    -- Step 2: Validate stock sufficiency
    IF v_available_stock < p_quantity THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business Error: Insufficient stock available for requested quantity.';
    END IF;

    -- Step 3: Decrement Product Stock
    UPDATE products 
    SET stock_quantity = stock_quantity - p_quantity 
    WHERE product_id = p_product_id;

    -- Step 4: Insert Order Header
    SET v_gen_order_num = CONCAT('ORD-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(FLOOR(RAND() * 9000 + 1000), 4, '0'));
    INSERT INTO orders (order_number, customer_id, order_status, order_date)
    VALUES (v_gen_order_num, p_customer_id, 'PROCESSING', NOW());
    SET v_new_order_id = LAST_INSERT_ID();

    -- Step 5: Insert Order Line Item
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (v_new_order_id, p_product_id, p_quantity, v_unit_price);

    -- Commit transaction
    COMMIT;
    SET p_order_number = v_gen_order_num;
END //

DELIMITER ;

-- Test Successful Order Placement
SET @out_order_no = '';
CALL sp_place_order(1, 2, 3, @out_order_no);
SELECT @out_order_no AS generated_order_number;


-- ============================================================================
-- TASK 3: Stored Function fn_order_total_with_tax
-- ============================================================================
DELIMITER //

DROP FUNCTION IF EXISTS fn_order_total_with_tax //
CREATE FUNCTION fn_order_total_with_tax(
    p_order_id INT,
    p_tax_rate DECIMAL(5, 2)
) 
RETURNS DECIMAL(12, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_subtotal DECIMAL(12, 2);
    DECLARE v_grand_total DECIMAL(12, 2);

    SELECT COALESCE(SUM(quantity * unit_price), 0.00)
    INTO v_subtotal
    FROM order_items
    WHERE order_id = p_order_id;

    SET v_grand_total = v_subtotal + (v_subtotal * (p_tax_rate / 100.00));
    RETURN ROUND(v_grand_total, 2);
END //

DELIMITER ;

-- Test Function in a SELECT query
SELECT 
    o.order_id,
    o.order_number,
    c.customer_name,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS subtotal,
    fn_order_total_with_tax(o.order_id, 18.00) AS total_with_18pct_gst
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_number, c.customer_name;
