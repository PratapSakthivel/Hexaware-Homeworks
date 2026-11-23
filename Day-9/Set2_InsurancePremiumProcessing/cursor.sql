-- ============================================================================
-- Day 9: Views, Stored Procedures, Functions and Cursors – MySQL 8.4 LTS
-- Set 2: Insurance Premium Processing
-- File: cursor.sql
-- Description: Task 4 – Cursor with NOT FOUND handler that loops over policies
--              with a lapsed renewal due date, sets status to 'LAPSED',
--              and writes an audit row; then rewrites it as set-based.
-- ============================================================================

USE insurance_processing_db;

CREATE TABLE IF NOT EXISTS policy_status_audit (
    status_audit_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_id INT NOT NULL,
    previous_status VARCHAR(20) NOT NULL,
    new_status VARCHAR(20) NOT NULL,
    reason VARCHAR(150) NOT NULL,
    transitioned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_stat_pol FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
) ENGINE=InnoDB;

-- Seed overdue policies that should lapse
INSERT INTO policies (policy_id, policy_number, policyholder_id, plan_id, sum_assured, current_premium, claim_free_years, policy_status, renewal_due_date) VALUES
(101, 'POL-OVERDUE-01', 1, 1, 3000000.00, 10000.00, 0, 'DUE', DATE_SUB(CURDATE(), INTERVAL 45 DAY)),
(102, 'POL-OVERDUE-02', 2, 2, 1500000.00,  8500.00, 0, 'DUE', DATE_SUB(CURDATE(), INTERVAL 60 DAY));

-- ----------------------------------------------------------------------------
-- Method A: Cursor Procedure with NOT FOUND Handler
-- ----------------------------------------------------------------------------
DELIMITER //

DROP PROCEDURE IF EXISTS sp_cursor_lapse_overdue_policies //
CREATE PROCEDURE sp_cursor_lapse_overdue_policies(
    OUT p_total_lapsed INT
)
BEGIN
    DECLARE v_is_finished INT DEFAULT FALSE;
    DECLARE v_policy_id INT;
    DECLARE v_current_status VARCHAR(20);
    DECLARE v_due_date DATE;
    DECLARE v_counter INT DEFAULT 0;

    -- Cursor selecting policies past grace period (30 days overdue)
    DECLARE cur_overdue_policies CURSOR FOR
        SELECT policy_id, policy_status, renewal_due_date
        FROM policies
        WHERE policy_status IN ('ACTIVE', 'DUE')
          AND renewal_due_date < DATE_SUB(CURDATE(), INTERVAL 30 DAY);

    -- NOT FOUND Handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_is_finished = TRUE;

    OPEN cur_overdue_policies;

    lapse_loop: LOOP
        FETCH cur_overdue_policies INTO v_policy_id, v_current_status, v_due_date;
        IF v_is_finished THEN
            LEAVE lapse_loop;
        END IF;

        -- Update Policy Status
        UPDATE policies 
        SET policy_status = 'LAPSED' 
        WHERE policy_id = v_policy_id;

        -- Write Audit Trail
        INSERT INTO policy_status_audit (policy_id, previous_status, new_status, reason)
        VALUES (v_policy_id, v_current_status, 'LAPSED', CONCAT('Premium payment missed past grace period (Due: ', v_due_date, ')'));

        SET v_counter = v_counter + 1;
    END LOOP;

    CLOSE cur_overdue_policies;
    SET p_total_lapsed = v_counter;
END //

DELIMITER ;

-- Test Cursor Execution
SET @lapsed_count = 0;
CALL sp_cursor_lapse_overdue_policies(@lapsed_count);
SELECT @lapsed_count AS policies_lapsed_by_cursor;


-- ----------------------------------------------------------------------------
-- Method B: Set-Based Rewrite
-- ----------------------------------------------------------------------------
DELIMITER //

DROP PROCEDURE IF EXISTS sp_setbased_lapse_overdue_policies //
CREATE PROCEDURE sp_setbased_lapse_overdue_policies(
    OUT p_total_lapsed INT
)
BEGIN
    -- Step 1: Insert audit trail in set-based batch
    INSERT INTO policy_status_audit (policy_id, previous_status, new_status, reason)
    SELECT 
        policy_id, 
        policy_status, 
        'LAPSED', 
        CONCAT('Set-based lapse: Premium payment missed past grace period (Due: ', renewal_due_date, ')')
    FROM policies
    WHERE policy_status IN ('ACTIVE', 'DUE')
      AND renewal_due_date < DATE_SUB(CURDATE(), INTERVAL 30 DAY);

    -- Step 2: Atomic bulk update
    UPDATE policies
    SET policy_status = 'LAPSED'
    WHERE policy_status IN ('ACTIVE', 'DUE')
      AND renewal_due_date < DATE_SUB(CURDATE(), INTERVAL 30 DAY);

    SET p_total_lapsed = ROW_COUNT();
END //

DELIMITER ;

SET @set_lapsed = 0;
CALL sp_setbased_lapse_overdue_policies(@set_lapsed);
SELECT @set_lapsed AS policies_lapsed_by_setbased;
