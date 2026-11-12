-- ============================================================================
-- Day 5: Databases, Normalisation and Data Definition - MySQL 8.4 LTS
-- Set 1: Retail Inventory Management
-- File: seed_data.sql
-- Description: Inserts at least 10 rows per table, demonstrates 4 deliberate
--              failing inserts, and executes UPDATE / DELETE with SELECT before/after.
-- ============================================================================

USE retail_inventory_db;

-- ----------------------------------------------------------------------------
-- 1. SEED DATA: At least 10 rows per table
-- ----------------------------------------------------------------------------

-- Insert 10 Suppliers
INSERT INTO suppliers (supplier_id, supplier_name, supplier_phone) VALUES
(1, 'Apex Electronics Ltd', '+1-555-0101'),
(2, 'BlueWave Logistics Goods', '+1-555-0102'),
(3, 'Cascade Fresh Foods', '+1-555-0103'),
(4, 'Delta Office Supplies', '+1-555-0104'),
(5, 'Echo Apparel Group', '+1-555-0105'),
(6, 'Frontier Hardware Inc', '+1-555-0106'),
(7, 'Golden Harvest Organics', '+1-555-0107'),
(8, 'Horizon Home Living', '+1-555-0108'),
(9, 'Infinity Sports Gear', '+1-555-0109'),
(10, 'Junction Toy Dist', '+1-555-0110');

-- Insert 10 Warehouses
INSERT INTO warehouses (warehouse_id, warehouse_name, location) VALUES
(1, 'North Distribution Center', 'Chicago, IL'),
(2, 'South Regional Hub', 'Dallas, TX'),
(3, 'East Coast Gateway', 'Newark, NJ'),
(4, 'West Coast Depot', 'Oakland, CA'),
(5, 'Midwest Logistics Hub', 'Indianapolis, IN'),
(6, 'Pacific Northwest Vault', 'Seattle, WA'),
(7, 'Rocky Mountain Depot', 'Denver, CO'),
(8, 'Southeast Fulfillment Center', 'Atlanta, GA'),
(9, 'Central Valley Storage', 'Phoenix, AZ'),
(10, 'Great Lakes Terminal', 'Cleveland, OH');

-- Insert 12 Products (minimum 10 rows)
INSERT INTO products (sku, product_name, category, supplier_id) VALUES
('SKU-1001', 'Wireless Noise-Canceling Headphones', 'Electronics', 1),
('SKU-1002', 'Mechanical Gaming Keyboard', 'Electronics', 1),
('SKU-1003', 'Ergonomic Mesh Office Chair', 'Furniture', 4),
('SKU-1004', 'Adjustable Standing Desk 48-inch', 'Furniture', 4),
('SKU-1005', 'Organic Cold Brew Coffee Beans 1kg', 'Beverages', 3),
('SKU-1006', 'Natural Almond Butter 500g', 'Groceries', 7),
('SKU-1007', 'Performance Running Shoes', 'Footwear', 9),
('SKU-1008', 'Dri-Fit Workout T-Shirt', 'Apparel', 5),
('SKU-1009', 'Heavy-Duty Cordless Drill 20V', 'Hardware', 6),
('SKU-1010', 'Stainless Steel Cookware Set 10pc', 'Kitchenware', 8),
('SKU-1011', 'Remote-Controlled Drone 4K', 'Toys', 10),
('SKU-DISC-99', 'Old Generation Analog Thermostat', 'Hardware', 6);

-- Insert 12 Inventory Stock Records (minimum 10 rows)
INSERT INTO inventory (sku, warehouse_id, quantity, reorder_level) VALUES
('SKU-1001', 1, 150, 25),
('SKU-1001', 4, 85, 20),
('SKU-1002', 1, 120, 30),
('SKU-1003', 2, 45, 10),
('SKU-1004', 2, 30, 8),
('SKU-1005', 3, 500, 100),
('SKU-1006', 3, 240, 50),
('SKU-1007', 4, 95, 20),
('SKU-1008', 5, 310, 60),
('SKU-1009', 6, 65, 15),
('SKU-1010', 8, 140, 25),
('SKU-DISC-99', 1, 5, 10);

-- ----------------------------------------------------------------------------
-- 2. DEMONSTRATION: FOUR DELIBERATELY FAILING INSERTS
-- ----------------------------------------------------------------------------

-- Failure Demonstration 1: Duplicate Key (PK Violation on products.sku)
-- Expected MySQL Error: Error 1062 (23000): Duplicate entry 'SKU-1001' for key 'products.PRIMARY'
-- INSERT INTO products (sku, product_name, category, supplier_id)
-- VALUES ('SKU-1001', 'Duplicate Wireless Headphones', 'Electronics', 1);

-- Failure Demonstration 2: Missing Parent (Foreign Key Violation on products.supplier_id)
-- Expected MySQL Error: Error 1452 (23000): Cannot add or update a child row: a foreign key constraint fails
-- INSERT INTO products (sku, product_name, category, supplier_id)
-- VALUES ('SKU-9999', 'Ghost Supplier Widget', 'Electronics', 999);

-- Failure Demonstration 3: Negative Quantity (CHECK Constraint chk_inventory_quantity violation)
-- Expected MySQL Error: Error 3819 (HY000): Check constraint 'chk_inventory_quantity' is violated.
-- INSERT INTO inventory (sku, warehouse_id, quantity, reorder_level)
-- VALUES ('SKU-1002', 3, -15, 10);

-- Failure Demonstration 4: NULL in Mandatory Column (supplier_name cannot be null)
-- Expected MySQL Error: Error 1048 (23000): Column 'supplier_name' cannot be null
-- INSERT INTO suppliers (supplier_name, supplier_phone)
-- VALUES (NULL, '+1-555-9999');

-- ----------------------------------------------------------------------------
-- 3. UPDATE & DELETE WITH WHERE CLAUSE (BEFORE AND AFTER SELECTS)
-- ----------------------------------------------------------------------------

-- Requirement A: Update supplier phone number
-- [SELECT BEFORE UPDATE]
SELECT supplier_id, supplier_name, supplier_phone 
FROM suppliers 
WHERE supplier_id = 1;

-- [EXECUTE UPDATE]
UPDATE suppliers 
SET supplier_phone = '+1-555-8888' 
WHERE supplier_id = 1;

-- [SELECT AFTER UPDATE]
SELECT supplier_id, supplier_name, supplier_phone 
FROM suppliers 
WHERE supplier_id = 1;

-- Requirement B: Remove discontinued SKUs
-- [SELECT BEFORE DELETE]
SELECT i.inventory_id, i.sku, p.product_name, i.quantity 
FROM inventory i
JOIN products p ON i.sku = p.sku
WHERE i.sku = 'SKU-DISC-99';

-- [EXECUTE DELETE]
-- First remove inventory references due to ON DELETE RESTRICT
DELETE FROM inventory 
WHERE sku = 'SKU-DISC-99';

DELETE FROM products 
WHERE sku = 'SKU-DISC-99';

-- [SELECT AFTER DELETE]
SELECT sku, product_name 
FROM products 
WHERE sku = 'SKU-DISC-99';

-- ----------------------------------------------------------------------------
-- 4. SYSTEM DATABASE EXPLORATION (information_schema)
-- ----------------------------------------------------------------------------
SELECT 
    table_schema,
    table_name,
    engine,
    table_rows,
    data_length,
    create_time
FROM information_schema.tables
WHERE table_schema = 'retail_inventory_db'
ORDER BY table_name;
