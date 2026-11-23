-- ============================================================================
-- Day 9: Views, Stored Procedures, Functions and Cursors – MySQL 8.4 LTS
-- Set 2: Insurance Premium Processing
-- File: procedures.sql
-- Description: Tasks 2, 3 & 5:
--              Task 2: sp_renew_policy with validations, premium recalculation,
--                      audit row, transaction & exit handler.
--              Task 3: fn_premium_with_no_claim_discount and reporting query.
--              Task 5: INOUT parameter passing running count of processed policies.
-- ============================================================================

USE insurance_processing_db;

-- Renewal Audit Table
CREATE TABLE IF NOT EXISTS renewal_audit_log (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_id INT NOT NULL,
    old_premium DECIMAL(12, 2) NOT NULL,
    new_premium DECIMAL(12, 2) NOT NULL,
    ncd_percentage DECIMAL(5, 2) NOT NULL,
    renewed_until DATE NOT NULL,
    processed_by VARCHAR(50) NOT NULL DEFAULT 'SYSTEM_POLICY_WORKER',
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_pol FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
) ENGINE=InnoDB;

-- ============================================================================
-- TASK 3: Stored Function fn_premium_with_no_claim_discount
-- ============================================================================
DELIMITER //

DROP FUNCTION IF EXISTS fn_premium_with_no_claim_discount //
CREATE FUNCTION fn_premium_with_no_claim_discount(
    p_base_premium DECIMAL(12, 2),
    p_claim_free_years INT
) 
RETURNS DECIMAL(12, 2)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_discount_pct DECIMAL(5, 2) DEFAULT 0.00;
    DECLARE v_discounted_premium DECIMAL(12, 2);

    -- Standard IRDAI / General Insurance No-Claim Discount (NCD) slabs
    IF p_claim_free_years >= 5 THEN
        SET v_discount_pct = 50.00;
    ELSEIF p_claim_free_years = 4 THEN
        SET v_discount_pct = 45.00;
    ELSEIF p_claim_free_years = 3 THEN
        SET v_discount_pct = 35.00;
    ELSEIF p_claim_free_years = 2 THEN
        SET v_discount_pct = 25.00;
    ELSEIF p_claim_free_years = 1 THEN
        SET v_discount_pct = 20.00;
    ELSE
        SET v_discount_pct = 0.00;
    END IF;

    SET v_discounted_premium = p_base_premium - (p_base_premium * (v_discount_pct / 100.00));
    RETURN ROUND(v_discounted_premium, 2);
END //

DELIMITER ;

-- ============================================================================
-- TASK 2 & 5: sp_renew_policy with Validation, Exit Handler & INOUT Parameter
-- ============================================================================
DELIMITER //

DROP PROCEDURE IF EXISTS sp_renew_policy //
CREATE PROCEDURE sp_renew_policy(
    IN p_policy_id INT,
    INOUT p_running_processed_count INT,
    OUT p_renewal_status VARCHAR(150)
)
proc_label: BEGIN
    DECLARE v_current_status VARCHAR(20);
    DECLARE v_old_premium DECIMAL(12, 2);
    DECLARE v_claim_free_years INT;
    DECLARE v_new_premium DECIMAL(12, 2);
    DECLARE v_has_pending_claim INT;
    DECLARE v_current_due_date DATE;
    DECLARE v_new_due_date DATE;

    -- Exit Handler for SQLEXCEPTION
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_renewal_status = 'ERROR: Database transaction exception occurred. Rollback executed.';
    END;

    -- Begin Transaction
    START TRANSACTION;

    -- Step 1: Lock policy row and fetch state
    SELECT policy_status, current_premium, claim_free_years, renewal_due_date
    INTO v_current_status, v_old_premium, v_claim_free_years, v_current_due_date
    FROM policies
    WHERE policy_id = p_policy_id
    FOR UPDATE;

    IF v_current_status IS NULL THEN
        ROLLBACK;
        SET p_renewal_status = 'REJECTED: Policy ID does not exist.';
        LEAVE proc_label;
    END IF;

    IF v_current_status NOT IN ('ACTIVE', 'DUE') THEN
        ROLLBACK;
        SET p_renewal_status = CONCAT('REJECTED: Cannot renew policy in ', v_current_status, ' status.');
        LEAVE proc_label;
    END IF;

    -- Step 2: Validate that no pending/submitted claims exist
    SELECT COUNT(*) INTO v_has_pending_claim
    FROM claims
    WHERE policy_id = p_policy_id
      AND claim_status IN ('SUBMITTED', 'UNDER_REVIEW');

    IF v_has_pending_claim > 0 THEN
        ROLLBACK;
        SET p_renewal_status = 'REJECTED: Policy has pending claims under review; renewal blocked.';
        LEAVE proc_label;
    END IF;

    -- Step 3: Recalculate premium using NCD function
    SET v_new_premium = fn_premium_with_no_claim_discount(v_old_premium, v_claim_free_years + 1);
    SET v_new_due_date = DATE_ADD(v_current_due_date, INTERVAL 1 YEAR);

    -- Step 4: Update Policy status & validity
    UPDATE policies
    SET policy_status = 'ACTIVE',
        claim_free_years = claim_free_years + 1,
        current_premium = v_new_premium,
        renewal_due_date = v_new_due_date
    WHERE policy_id = p_policy_id;

    -- Step 5: Insert Audit Row
    INSERT INTO renewal_audit_log (policy_id, old_premium, new_premium, ncd_percentage, renewed_until)
    VALUES (
        p_policy_id, 
        v_old_premium, 
        v_new_premium, 
        ROUND(((v_old_premium - v_new_premium) * 100.0) / v_old_premium, 2), 
        v_new_due_date
    );

    -- Commit transaction
    COMMIT;

    -- Step 6: Increment INOUT counter
    SET p_running_processed_count = COALESCE(p_running_processed_count, 0) + 1;
    SET p_renewal_status = CONCAT('SUCCESS: Policy ', p_policy_id, ' renewed. New Premium: INR ', v_new_premium);
END //

DELIMITER ;

-- Test Execution
SET @counter = 0;
SET @status = '';
CALL sp_renew_policy(1, @counter, @status);
SELECT @status AS renewal_result, @counter AS running_processed_count;
