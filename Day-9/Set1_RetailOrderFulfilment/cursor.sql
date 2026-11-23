-- ============================================================================
-- Day 9: Views, Stored Procedures, Functions and Cursors – MySQL 8.4 LTS
-- Set 1: Retail Order Fulfilment
-- File: cursor.sql
-- Description: Task 4 – Cursor-based procedure with NOT FOUND handler that walks
--              orders pending for more than 3 days and inserts follow-up actions;
--              then rewrites it as a single high-performance set-based statement.
-- ============================================================================

USE retail_fulfilment_db;

-- Follow-up Audit Table
CREATE TABLE IF NOT EXISTS order_followups (
    followup_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    order_number VARCHAR(30) NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    notes TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_followup_ord FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB;

-- Seed an aged pending order (> 3 days old)
INSERT INTO orders (order_id, order_number, customer_id, order_status, order_date) VALUES
(101, 'ORD-2026-OLD-01', 1, 'PENDING', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(102, 'ORD-2026-OLD-02', 2, 'PENDING', DATE_SUB(NOW(), INTERVAL 4 DAY));

-- ----------------------------------------------------------------------------
-- Method A: Cursor-based Procedure with NOT FOUND Handler
-- ----------------------------------------------------------------------------
DELIMITER //

DROP PROCEDURE IF EXISTS sp_cursor_flag_aged_pending_orders //
CREATE PROCEDURE sp_cursor_flag_aged_pending_orders(
    OUT p_flagged_count INT
)
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_order_id INT;
    DECLARE v_order_num VARCHAR(30);
    DECLARE v_order_date DATETIME;
    DECLARE v_count INT DEFAULT 0;

    -- Declare Cursor for pending orders older than 3 days
    DECLARE cur_aged_orders CURSOR FOR
        SELECT order_id, order_number, order_date
        FROM orders
        WHERE order_status = 'PENDING'
          AND order_date < DATE_SUB(NOW(), INTERVAL 3 DAY);

    -- Declare NOT FOUND Handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    OPEN cur_aged_orders;

    read_loop: LOOP
        FETCH cur_aged_orders INTO v_order_id, v_order_num, v_order_date;
        IF v_done THEN
            LEAVE read_loop;
        END IF;

        -- Insert follow-up escalation row per order
        INSERT INTO order_followups (order_id, order_number, action_type, notes)
        VALUES (
            v_order_id, 
            v_order_num, 
            'ESCALATION_PENDING_FULFILMENT', 
            CONCAT('Order pending since ', v_order_date, '; automated follow-up ticket generated.')
        );

        SET v_count = v_count + 1;
    END LOOP;

    CLOSE cur_aged_orders;
    SET p_flagged_count = v_count;
END //

DELIMITER ;

-- Test Cursor Procedure
SET @cnt = 0;
CALL sp_cursor_flag_aged_pending_orders(@cnt);
SELECT @cnt AS orders_flagged_via_cursor;


-- ----------------------------------------------------------------------------
-- Method B: Set-Based Rewrite (High-Performance Single Query)
-- ----------------------------------------------------------------------------
DELIMITER //

DROP PROCEDURE IF EXISTS sp_setbased_flag_aged_pending_orders //
CREATE PROCEDURE sp_setbased_flag_aged_pending_orders(
    OUT p_flagged_count INT
)
BEGIN
    -- Single atomic set-based insert without row-by-row context switches
    INSERT INTO order_followups (order_id, order_number, action_type, notes)
    SELECT 
        o.order_id,
        o.order_number,
        'ESCALATION_SET_BASED',
        CONCAT('Order pending since ', o.order_date, '; set-based follow-up ticket generated.')
    FROM orders o
    WHERE o.order_status = 'PENDING'
      AND o.order_date < DATE_SUB(NOW(), INTERVAL 3 DAY)
      AND NOT EXISTS (
          SELECT 1 FROM order_followups f 
          WHERE f.order_id = o.order_id AND f.action_type = 'ESCALATION_SET_BASED'
      );

    SET p_flagged_count = ROW_COUNT();
END //

DELIMITER ;

SET @set_cnt = 0;
CALL sp_setbased_flag_aged_pending_orders(@set_cnt);
SELECT @set_cnt AS orders_flagged_via_setbased;
