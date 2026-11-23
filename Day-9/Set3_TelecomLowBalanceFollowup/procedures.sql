-- ============================================================================
-- Day 9: Views, Stored Procedures, Functions and Cursors – MySQL 8.4 LTS
-- Set 3: Telecom Low-Balance Follow-up
-- File: procedures.sql
-- Description: Tasks 2, 3 & 5:
--              Task 2: sp_recharge with validation, transactional balance update,
--                      recharge history insert, and new balance OUT parameter.
--              Task 3: fn_validity_days_left and query usage.
--              Task 5: DECLARE ... HANDLER FOR SQLEXCEPTION with custom SIGNAL.
-- ============================================================================

USE telecom_followup_db;

-- ============================================================================
-- TASK 3: Stored Function fn_validity_days_left
-- ============================================================================
DELIMITER //

DROP FUNCTION IF EXISTS fn_validity_days_left //
CREATE FUNCTION fn_validity_days_left(
    p_expiry_date DATE
) 
RETURNS INT
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_days_diff INT;
    SET v_days_diff = DATEDIFF(p_expiry_date, CURDATE());
    
    IF v_days_diff < 0 THEN
        RETURN 0; -- Expired
    ELSE
        RETURN v_days_diff;
    END IF;
END //

DELIMITER ;

-- Test Function in Query
SELECT 
    subscriber_id,
    mobile_number,
    full_name,
    validity_expiry_date,
    fn_validity_days_left(validity_expiry_date) AS days_remaining
FROM subscribers
WHERE plan_type = 'PREPAID';


-- ============================================================================
-- TASK 2 & 5: sp_recharge with Validation, Transaction & SQLEXCEPTION Handler
-- ============================================================================
DELIMITER //

DROP PROCEDURE IF EXISTS sp_recharge //
CREATE PROCEDURE sp_recharge(
    IN p_subscriber_id INT,
    IN p_plan_id INT,
    IN p_payment_mode VARCHAR(20),
    OUT p_new_balance DECIMAL(10, 2),
    OUT p_status_message VARCHAR(150)
)
proc_label: BEGIN
    DECLARE v_sub_exists INT;
    DECLARE v_plan_price DECIMAL(10, 2);
    DECLARE v_plan_talktime DECIMAL(10, 2);
    DECLARE v_plan_days INT;
    DECLARE v_current_expiry DATE;
    DECLARE v_new_expiry DATE;

    -- Generic Error Handler for Database Exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_new_balance = 0.00;
        SET p_status_message = 'ERROR: Database transaction exception occurred during recharge processing. Rollback performed.';
    END;

    -- Parameter Validation
    IF p_payment_mode NOT IN ('UPI', 'CREDIT_CARD', 'NET_BANKING', 'VOUCHER') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validation Error: Unsupported payment mode specified.';
    END IF;

    -- Validate Subscriber
    SELECT COUNT(*), validity_expiry_date INTO v_sub_exists, v_current_expiry
    FROM subscribers 
    WHERE subscriber_id = p_subscriber_id AND plan_type = 'PREPAID' AND status = 'ACTIVE';

    IF v_sub_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validation Error: Active prepaid subscriber not found for given ID.';
    END IF;

    -- Validate Plan
    SELECT price, talktime_amount, validity_days 
    INTO v_plan_price, v_plan_talktime, v_plan_days
    FROM recharge_plans 
    WHERE plan_id = p_plan_id;

    IF v_plan_price IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Validation Error: Specified recharge plan ID does not exist.';
    END IF;

    -- Begin Atomic Recharge Transaction
    START TRANSACTION;

    -- Lock subscriber record
    SELECT current_balance INTO p_new_balance 
    FROM subscribers 
    WHERE subscriber_id = p_subscriber_id 
    FOR UPDATE;

    -- Calculate Extended Expiry
    IF v_current_expiry > CURDATE() THEN
        SET v_new_expiry = DATE_ADD(v_current_expiry, INTERVAL v_plan_days DAY);
    ELSE
        SET v_new_expiry = DATE_ADD(CURDATE(), INTERVAL v_plan_days DAY);
    END IF;

    -- Update subscriber balance & validity
    UPDATE subscribers
    SET current_balance = current_balance + v_plan_talktime,
        validity_expiry_date = v_new_expiry
    WHERE subscriber_id = p_subscriber_id;

    -- Insert into recharge audit history
    INSERT INTO recharge_history (subscriber_id, plan_id, amount_paid, talktime_credited, recharge_date, payment_mode)
    VALUES (p_subscriber_id, p_plan_id, v_plan_price, v_plan_talktime, NOW(), p_payment_mode);

    -- Fetch final committed balance
    SELECT current_balance INTO p_new_balance 
    FROM subscribers 
    WHERE subscriber_id = p_subscriber_id;

    COMMIT;
    SET p_status_message = CONCAT('SUCCESS: Recharged with plan ', p_plan_id, '. Talktime credited: INR ', v_plan_talktime);
END //

DELIMITER ;

-- Test Successful Recharge
SET @updated_bal = 0.00;
SET @out_msg = '';
CALL sp_recharge(1, 1, 'UPI', @updated_bal, @out_msg);
SELECT @updated_bal AS final_balance, @out_msg AS recharge_feedback;
