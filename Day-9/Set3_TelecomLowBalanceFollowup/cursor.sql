-- ============================================================================
-- Day 9: Views, Stored Procedures, Functions and Cursors – MySQL 8.4 LTS
-- Set 3: Telecom Low-Balance Follow-up
-- File: cursor.sql
-- Description: Task 4 – Cursor with NOT FOUND handler that inserts notification
--              rows for subscribers with balance < 50 units, compared against
--              a single set-based INSERT ... SELECT statement.
-- ============================================================================

USE telecom_followup_db;

-- Notifications Dispatch Table
CREATE TABLE IF NOT EXISTS subscriber_notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    subscriber_id INT NOT NULL,
    mobile_number VARCHAR(15) NOT NULL,
    current_balance DECIMAL(10, 2) NOT NULL,
    notification_channel ENUM('SMS', 'WHATSAPP', 'PUSH_ALERT') NOT NULL DEFAULT 'SMS',
    message_content TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notif_sub FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Method A: Cursor Procedure with NOT FOUND Handler
-- ----------------------------------------------------------------------------
DELIMITER //

DROP PROCEDURE IF EXISTS sp_cursor_notify_low_balance //
CREATE PROCEDURE sp_cursor_notify_low_balance(
    OUT p_notifications_sent INT
)
BEGIN
    DECLARE v_is_end INT DEFAULT FALSE;
    DECLARE v_sub_id INT;
    DECLARE v_mobile VARCHAR(15);
    DECLARE v_bal DECIMAL(10, 2);
    DECLARE v_count INT DEFAULT 0;

    -- Declare cursor selecting active prepaid users below 50 units
    DECLARE cur_low_balance CURSOR FOR
        SELECT subscriber_id, mobile_number, current_balance
        FROM subscribers
        WHERE plan_type = 'PREPAID'
          AND status = 'ACTIVE'
          AND current_balance < 50.00;

    -- Declare Handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_is_end = TRUE;

    OPEN cur_low_balance;

    read_loop: LOOP
        FETCH cur_low_balance INTO v_sub_id, v_mobile, v_bal;
        IF v_is_end THEN
            LEAVE read_loop;
        END IF;

        -- Insert notification row
        INSERT INTO subscriber_notifications (subscriber_id, mobile_number, current_balance, notification_channel, message_content)
        VALUES (
            v_sub_id,
            v_mobile,
            v_bal,
            'SMS',
            CONCAT('Dear customer, your prepaid balance is INR ', v_bal, ', which is below INR 50. Please recharge soon to enjoy uninterrupted calls.')
        );

        SET v_count = v_count + 1;
    END LOOP;

    CLOSE cur_low_balance;
    SET p_notifications_sent = v_count;
END //

DELIMITER ;

-- Test Cursor Procedure
SET @cur_sent = 0;
CALL sp_cursor_notify_low_balance(@cur_sent);
SELECT @cur_sent AS notifications_dispatched_via_cursor;


-- ----------------------------------------------------------------------------
-- Method B: Set-Based Rewrite (Single INSERT ... SELECT)
-- ----------------------------------------------------------------------------
DELIMITER //

DROP PROCEDURE IF EXISTS sp_setbased_notify_low_balance //
CREATE PROCEDURE sp_setbased_notify_low_balance(
    OUT p_notifications_sent INT
)
BEGIN
    -- Declarative set-based insert executed in a single atomic database operation
    INSERT INTO subscriber_notifications (subscriber_id, mobile_number, current_balance, notification_channel, message_content)
    SELECT 
        subscriber_id,
        mobile_number,
        current_balance,
        'WHATSAPP',
        CONCAT('Dear customer, your prepaid balance is INR ', current_balance, '. Recharge now via our app for 10% extra talktime!')
    FROM subscribers
    WHERE plan_type = 'PREPAID'
      AND status = 'ACTIVE'
      AND current_balance < 50.00;

    SET p_notifications_sent = ROW_COUNT();
END //

DELIMITER ;

-- Test Set-Based Procedure
SET @set_sent = 0;
CALL sp_setbased_notify_low_balance(@set_sent);
SELECT @set_sent AS notifications_dispatched_via_setbased;
