-- ============================================================================
-- Day 10: Triggers – MySQL 8.4 LTS
-- Set 1: Retail Price Change Audit
-- File: triggers.sql
-- Description: Tasks 1 & 2:
--              Task 1: AFTER UPDATE trigger on product_price recording old price,
--                      new price, current user, and timestamp into price_audit using OLD and NEW.
--              Task 2: BEFORE UPDATE trigger rejecting any price below cost
--                      using SIGNAL SQLSTATE '45000' with a clear message.
-- ============================================================================

DROP DATABASE IF EXISTS retail_price_audit_db;
CREATE DATABASE retail_price_audit_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE retail_price_audit_db;

-- ----------------------------------------------------------------------------
-- Base Tables
-- ----------------------------------------------------------------------------
CREATE TABLE product_price (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(30) NOT NULL UNIQUE,
    product_name VARCHAR(100) NOT NULL,
    cost_price DECIMAL(10, 2) NOT NULL,
    selling_price DECIMAL(10, 2) NOT NULL,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_initial_price CHECK (selling_price >= cost_price)
) ENGINE=InnoDB;

CREATE TABLE price_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    sku VARCHAR(30) NOT NULL,
    old_selling_price DECIMAL(10, 2) NOT NULL,
    new_selling_price DECIMAL(10, 2) NOT NULL,
    price_delta DECIMAL(10, 2) NOT NULL,
    changed_by VARCHAR(100) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_prod FOREIGN KEY (product_id) REFERENCES product_price(product_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Baseline Data
-- ----------------------------------------------------------------------------
INSERT INTO product_price (product_id, sku, product_name, cost_price, selling_price) VALUES
(1, 'ELEC-4K-TV',  'Smart LED TV 55-inch', 32000.00, 44999.00),
(2, 'ELEC-SND-BAR', 'Dolby Soundbar 300W',   8000.00, 12499.00),
(3, 'APPL-REF-INV', 'Frost Free 340L Refrig', 22000.00, 29999.00),
(4, 'APPL-WSH-MCH', 'Front Load Washer 8kg',  26000.00, 35499.00);

-- ============================================================================
-- TASK 2: BEFORE UPDATE Trigger - Guard Against Below-Cost Pricing
-- ============================================================================
DELIMITER //

DROP TRIGGER IF EXISTS trg_product_price_before_update //
CREATE TRIGGER trg_product_price_before_update
BEFORE UPDATE ON product_price
FOR EACH ROW
BEGIN
    -- Guard: Reject selling price lower than product cost
    IF NEW.selling_price < NEW.cost_price THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business Rule Violation: Selling price cannot be set below unit cost price.';
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- TASK 1: AFTER UPDATE Trigger - Record Tamper-Evident Price Audit Log
-- ============================================================================
DELIMITER //

DROP TRIGGER IF EXISTS trg_product_price_after_update //
CREATE TRIGGER trg_product_price_after_update
AFTER UPDATE ON product_price
FOR EACH ROW
BEGIN
    -- Only log when selling price actually changes
    IF OLD.selling_price <> NEW.selling_price THEN
        INSERT INTO price_audit (
            product_id,
            sku,
            old_selling_price,
            new_selling_price,
            price_delta,
            changed_by,
            changed_at
        ) VALUES (
            OLD.product_id,
            OLD.sku,
            OLD.selling_price,
            NEW.selling_price,
            NEW.selling_price - OLD.selling_price,
            CURRENT_USER(),
            NOW()
        );
    END IF;
END //

DELIMITER ;
