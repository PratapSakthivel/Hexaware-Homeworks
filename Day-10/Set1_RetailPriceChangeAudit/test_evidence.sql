-- ============================================================================
-- Day 10: Triggers – MySQL 8.4 LTS
-- Set 1: Retail Price Change Audit
-- File: test_evidence.sql
-- Description: Tasks 3 & 5:
--              Task 3: Test single-row and multi-row updates and record evidence;
--                      demonstrate that MySQL triggers fire per-row.
--              Task 5: Query information_schema to inspect trigger definitions.
-- ============================================================================

USE retail_price_audit_db;

-- ----------------------------------------------------------------------------
-- 1. Test Single-Row Valid Price Update
-- ----------------------------------------------------------------------------
SELECT '=== BEFORE SINGLE-ROW UPDATE ===' AS step;
SELECT product_id, sku, product_name, selling_price FROM product_price WHERE product_id = 1;

UPDATE product_price 
SET selling_price = 47999.00 
WHERE product_id = 1;

SELECT '=== AFTER SINGLE-ROW UPDATE ===' AS step;
SELECT product_id, sku, product_name, selling_price FROM product_price WHERE product_id = 1;

SELECT '=== AUDIT TABLE AFTER SINGLE-ROW UPDATE ===' AS step;
SELECT * FROM price_audit;


-- ----------------------------------------------------------------------------
-- 2. Test Multi-Row Batch Update (Trigger Fires Row-Level For Each Row)
-- ----------------------------------------------------------------------------
-- Increase price by 5% across all products
UPDATE product_price 
SET selling_price = ROUND(selling_price * 1.05, 2);

SELECT '=== AUDIT TABLE AFTER MULTI-ROW UPDATE (4 INDIVIDUAL AUDIT ROWS INSERTED) ===' AS step;
SELECT audit_id, product_id, sku, old_selling_price, new_selling_price, price_delta, changed_by FROM price_audit;


-- ----------------------------------------------------------------------------
-- 3. Test Violation Rejection via BEFORE UPDATE Trigger
-- Attempt to set selling price to 20,000.00 for Product 1 (Cost is 32,000.00)
-- ----------------------------------------------------------------------------
-- Expected: ERROR 1644 (45000): Business Rule Violation: Selling price cannot be set below unit cost price.
/*
UPDATE product_price 
SET selling_price = 20000.00 
WHERE product_id = 1;
*/


-- ----------------------------------------------------------------------------
-- 4. TASK 5: Inspect Triggers from information_schema
-- ----------------------------------------------------------------------------
SELECT 
    trigger_schema,
    trigger_name,
    event_manipulation AS event_type,
    event_object_table AS target_table,
    action_timing AS timing,
    action_orientation AS orientation,
    created
FROM information_schema.triggers
WHERE trigger_schema = 'retail_price_audit_db'
ORDER BY event_object_table, action_timing;
