-- ============================================================================
-- Day 5: Databases, Normalisation and Data Definition - MySQL 8.4 LTS
-- Set 1: Retail Inventory Management
-- File: schema.sql
-- ============================================================================

DROP DATABASE IF EXISTS retail_inventory_db;
CREATE DATABASE retail_inventory_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE retail_inventory_db;

-- 1. Suppliers Table
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_supplier_name UNIQUE (supplier_name)
) ENGINE=InnoDB;

-- 2. Warehouses Table
CREATE TABLE warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_name VARCHAR(100) NOT NULL,
    location VARCHAR(150) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_warehouse_name UNIQUE (warehouse_name)
) ENGINE=InnoDB;

-- 3. Products Table
CREATE TABLE products (
    sku VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(60) NOT NULL,
    supplier_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_products_supplier
        FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4. Inventory Table (Stock levels per product and warehouse)
CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(20) NOT NULL,
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 10,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_product_warehouse UNIQUE (sku, warehouse_id),
    CONSTRAINT chk_inventory_quantity CHECK (quantity >= 0),
    CONSTRAINT chk_reorder_level CHECK (reorder_level >= 0),
    CONSTRAINT fk_inventory_product
        FOREIGN KEY (sku) REFERENCES products(sku)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_warehouse
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;
