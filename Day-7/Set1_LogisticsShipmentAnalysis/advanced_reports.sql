-- ============================================================================
-- Day 7: Joins and Subqueries - MySQL 8.4 LTS
-- Set 1: Logistics Shipment Analysis
-- File: advanced_reports.sql
-- Description: Schema, seed data, and 10 advanced business queries covering
--              INNER, LEFT, RIGHT, Self Joins, Subqueries (IN, EXISTS, ANY, ALL),
--              subquery-to-join rewrites, and nested subqueries.
-- ============================================================================

DROP DATABASE IF EXISTS logistics_shipment_db;
CREATE DATABASE logistics_shipment_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE logistics_shipment_db;

-- ----------------------------------------------------------------------------
-- 1. SCHEMA DEFINITION
-- ----------------------------------------------------------------------------

CREATE TABLE hubs (
    hub_id INT AUTO_INCREMENT PRIMARY KEY,
    hub_code VARCHAR(10) NOT NULL UNIQUE,
    hub_name VARCHAR(100) NOT NULL,
    city VARCHAR(60) NOT NULL,
    state VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE carriers (
    carrier_id INT AUTO_INCREMENT PRIMARY KEY,
    carrier_name VARCHAR(100) NOT NULL,
    service_tier VARCHAR(30) NOT NULL -- Express, Standard, Economy
) ENGINE=InnoDB;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_type VARCHAR(30) NOT NULL -- Enterprise, Retail, Wholesale
) ENGINE=InnoDB;

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    hub_id INT NOT NULL,
    manager_id INT NULL, -- Self-referencing FK
    CONSTRAINT fk_emp_hub FOREIGN KEY (hub_id) REFERENCES hubs(hub_id),
    CONSTRAINT fk_emp_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB;

CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    tracking_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    carrier_id INT NOT NULL,
    origin_hub_id INT NOT NULL,
    destination_hub_id INT NOT NULL,
    shipping_cost DECIMAL(10, 2) NOT NULL,
    promised_delivery_date DATE NOT NULL,
    actual_delivery_date DATE NULL, -- NULL indicates in-transit
    status VARCHAR(20) NOT NULL, -- DELIVERED, IN_TRANSIT, DELAYED
    CONSTRAINT fk_ship_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_ship_carrier FOREIGN KEY (carrier_id) REFERENCES carriers(carrier_id),
    CONSTRAINT fk_ship_orig_hub FOREIGN KEY (origin_hub_id) REFERENCES hubs(hub_id),
    CONSTRAINT fk_ship_dest_hub FOREIGN KEY (destination_hub_id) REFERENCES hubs(hub_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. SEED DATA POPULATION
-- ----------------------------------------------------------------------------

INSERT INTO hubs (hub_id, hub_code, hub_name, city, state) VALUES
(1, 'HUB-CHI', 'Midwest Gateway Hub', 'Chicago', 'IL'),
(2, 'HUB-NYC', 'Metro East Terminal', 'New York', 'NY'),
(3, 'HUB-DAL', 'Southern Central Terminal', 'Dallas', 'TX'),
(4, 'HUB-SFO', 'Bay Area Logistics Hub', 'San Francisco', 'CA'),
(5, 'HUB-MIA', 'Sunshine Distribution Center', 'Miami', 'FL'); -- Hub with NO outbound shipments

INSERT INTO carriers (carrier_id, carrier_name, service_tier) VALUES
(1, 'SwiftAir Express', 'Express'),
(2, 'CrossCountry Freight', 'Standard'),
(3, 'BlueLine Logistics', 'Economy'),
(4, 'Pinnacle Carriers', 'Standard');

INSERT INTO customers (customer_id, customer_name, customer_type) VALUES
(1, 'Apex Global Retail', 'Enterprise'),  -- Shipped to hubs 1, 2, 3, 4, 5 (All hubs!)
(2, 'Beacon Supplies Inc', 'Wholesale'),
(3, 'Crestview Hardware', 'Retail'),
(4, 'Dynamic Corp', 'Enterprise'),
(5, 'Echo E-Commerce', 'Retail');

INSERT INTO employees (employee_id, employee_name, role, hub_id, manager_id) VALUES
(1, 'Victoria Stone', 'VP Logistics Operations', 1, NULL),     -- Top Executive (No manager)
(2, 'Arthur Pendelton', 'Regional Director Midwest', 1, 1),
(3, 'Beatrice Vance', 'Hub Shift Supervisor', 1, 2),
(4, 'Carlos Gomez', 'Regional Director East', 2, 1),
(5, 'Diana Prince', 'Station Dispatcher', 2, 4),
(6, 'Edward Miller', 'Fleet Supervisor', 3, 2);

-- Shipments: Note delays (actual_delivery_date - promised_delivery_date > 2 days)
INSERT INTO shipments (shipment_id, tracking_number, customer_id, carrier_id, origin_hub_id, destination_hub_id, shipping_cost, promised_delivery_date, actual_delivery_date, status) VALUES
(1, 'TRK-1001', 1, 1, 1, 2, 450.00, '2026-10-05', '2026-10-09', 'DELIVERED'), -- 4 days delay (>2)
(2, 'TRK-1002', 1, 2, 1, 3, 320.00, '2026-10-08', '2026-10-12', 'DELIVERED'), -- 4 days delay (>2)
(3, 'TRK-1003', 1, 1, 1, 4, 600.00, '2026-10-12', '2026-10-13', 'DELIVERED'), -- 1 day delay
(4, 'TRK-1004', 1, 3, 1, 5, 280.00, '2026-10-15', '2026-10-15', 'DELIVERED'), -- 0 days delay
(5, 'TRK-1005', 1, 1, 1, 1, 150.00, '2026-10-18', '2026-10-18', 'DELIVERED'), -- 0 days delay (Apex shipped to all 5 hubs!)
(6, 'TRK-1006', 2, 2, 2, 1, 480.00, '2026-10-06', '2026-10-10', 'DELIVERED'), -- 4 days delay (>2)
(7, 'TRK-1007', 2, 3, 2, 3, 210.00, '2026-10-10', '2026-10-11', 'DELIVERED'), -- 1 day delay
(8, 'TRK-1008', 3, 1, 3, 2, 550.00, '2026-10-14', '2026-10-18', 'DELIVERED'), -- 4 days delay (>2)
(9, 'TRK-1009', 4, 4, 4, 1, 390.00, '2026-10-20', '2026-10-21', 'DELIVERED'), -- 1 day delay
(10, 'TRK-1010', 4, 2, 4, 3, 720.00, '2026-10-22', '2026-10-26', 'DELIVERED'),-- 4 days delay (>2)
(11, 'TRK-1011', 5, 3, 2, 4, 190.00, '2026-10-25', '2026-10-25', 'DELIVERED'),
(12, 'TRK-1012', 3, 1, 3, 4, 420.00, '2026-10-28', '2026-10-29', 'DELIVERED');
-- Notice: HUB 5 (HUB-MIA) has ZERO outbound shipments (origin_hub_id = 5 does not exist).

-- ----------------------------------------------------------------------------
-- 3. TEN BUSINESS QUESTIONS SOLVED
-- ----------------------------------------------------------------------------

-- Q1: Shipments delayed by more than two days with carrier name (INNER JOIN)
SELECT 
    s.tracking_number,
    c.carrier_name,
    s.promised_delivery_date,
    s.actual_delivery_date,
    DATEDIFF(s.actual_delivery_date, s.promised_delivery_date) AS delay_in_days,
    s.shipping_cost
FROM shipments s
INNER JOIN carriers c ON s.carrier_id = c.carrier_id
WHERE s.actual_delivery_date IS NOT NULL 
  AND DATEDIFF(s.actual_delivery_date, s.promised_delivery_date) > 2
ORDER BY delay_in_days DESC;

-- Q2: Hubs with no outbound shipments (LEFT JOIN)
SELECT 
    h.hub_id,
    h.hub_code,
    h.hub_name,
    h.city,
    h.state,
    COUNT(s.shipment_id) AS outbound_shipment_count
FROM hubs h
LEFT JOIN shipments s ON h.hub_id = s.origin_hub_id
GROUP BY h.hub_id, h.hub_code, h.hub_name, h.city, h.state
HAVING COUNT(s.shipment_id) = 0;

-- Q3: Employees with their supervisors (SELF JOIN)
SELECT 
    e.employee_id,
    e.employee_name AS employee_name,
    e.role AS employee_role,
    h.hub_name AS assigned_hub,
    COALESCE(m.employee_name, 'TOP EXECUTIVE / BOARD') AS supervisor_name,
    COALESCE(m.role, 'N/A') AS supervisor_role
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
INNER JOIN hubs h ON e.hub_id = h.hub_id
ORDER BY e.manager_id ASC, e.employee_id ASC;

-- Q4: Carriers and their total shipments handled (RIGHT JOIN demonstration)
SELECT 
    c.carrier_id,
    c.carrier_name,
    c.service_tier,
    COUNT(s.shipment_id) AS total_shipments_carried,
    COALESCE(SUM(s.shipping_cost), 0.00) AS total_freight_revenue
FROM shipments s
RIGHT JOIN carriers c ON s.carrier_id = c.carrier_id
GROUP BY c.carrier_id, c.carrier_name, c.service_tier
ORDER BY total_freight_revenue DESC;

-- Q5: Customers who shipped to every hub (Relational Division using ALL/COUNT)
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(DISTINCT s.destination_hub_id) AS distinct_hubs_reached
FROM customers c
JOIN shipments s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_type
HAVING COUNT(DISTINCT s.destination_hub_id) = (SELECT COUNT(*) FROM hubs);

-- Q6: Carriers whose average delivery delay is strictly above the overall average (Correlated Subquery)
SELECT 
    c.carrier_id,
    c.carrier_name,
    ROUND(AVG(DATEDIFF(s.actual_delivery_date, s.promised_delivery_date)), 2) AS carrier_avg_delay_days
FROM carriers c
JOIN shipments s ON c.carrier_id = s.carrier_id
WHERE s.actual_delivery_date IS NOT NULL
GROUP BY c.carrier_id, c.carrier_name
HAVING AVG(DATEDIFF(s.actual_delivery_date, s.promised_delivery_date)) > (
    SELECT AVG(DATEDIFF(actual_delivery_date, promised_delivery_date))
    FROM shipments
    WHERE actual_delivery_date IS NOT NULL
)
ORDER BY carrier_avg_delay_days DESC;

-- Q7: Customers who have shipped via Express tier carriers using EXISTS
SELECT 
    cust.customer_id,
    cust.customer_name,
    cust.customer_type
FROM customers cust
WHERE EXISTS (
    SELECT 1 
    FROM shipments s
    JOIN carriers car ON s.carrier_id = car.carrier_id
    WHERE s.customer_id = cust.customer_id
      AND car.service_tier = 'Express'
);

-- Q8: Shipments whose cost is higher than ANY shipment originating from Hub 3 (ANY operator)
SELECT 
    s.shipment_id,
    s.tracking_number,
    s.origin_hub_id,
    s.shipping_cost
FROM shipments s
WHERE s.origin_hub_id != 3
  AND s.shipping_cost > ANY (
      SELECT shipping_cost 
      FROM shipments 
      WHERE origin_hub_id = 3
  )
ORDER BY s.shipping_cost DESC;

-- Q9: Shipments whose cost is greater than ALL shipments handled by Economy carriers (ALL operator)
SELECT 
    s.shipment_id,
    s.tracking_number,
    s.carrier_id,
    s.shipping_cost
FROM shipments s
WHERE s.shipping_cost > ALL (
    SELECT s2.shipping_cost 
    FROM shipments s2
    JOIN carriers c ON s2.carrier_id = c.carrier_id
    WHERE c.service_tier = 'Economy'
)
ORDER BY s.shipping_cost ASC;

-- Q10: Nested Subquery: Second-highest shipping cost per origin hub
SELECT 
    orig.origin_hub_id,
    h.hub_name,
    orig.shipping_cost AS second_highest_cost
FROM shipments orig
JOIN hubs h ON orig.origin_hub_id = h.hub_id
WHERE orig.shipping_cost = (
    SELECT MAX(s2.shipping_cost)
    FROM shipments s2
    WHERE s2.origin_hub_id = orig.origin_hub_id
      AND s2.shipping_cost < (
          SELECT MAX(s3.shipping_cost)
          FROM shipments s3
          WHERE s3.origin_hub_id = orig.origin_hub_id
      )
)
GROUP BY orig.origin_hub_id, h.hub_name, orig.shipping_cost
ORDER BY orig.origin_hub_id ASC;

-- ----------------------------------------------------------------------------
-- 4. SUBQUERY VS JOIN REWRITES & PERFORMANCE COMPARISON
-- ----------------------------------------------------------------------------

-- Rewrite 1A (Subquery with IN):
SELECT customer_id, customer_name 
FROM customers 
WHERE customer_id IN (SELECT DISTINCT customer_id FROM shipments WHERE shipping_cost > 500.00);

-- Rewrite 1B (Equivalent INNER JOIN):
SELECT DISTINCT c.customer_id, c.customer_name
FROM customers c
INNER JOIN shipments s ON c.customer_id = s.customer_id
WHERE s.shipping_cost > 500.00;

-- Rewrite 2A (Subquery with NOT EXISTS):
SELECT hub_id, hub_name 
FROM hubs h 
WHERE NOT EXISTS (SELECT 1 FROM shipments s WHERE s.origin_hub_id = h.hub_id);

-- Rewrite 2B (Equivalent LEFT JOIN ... WHERE NULL):
SELECT h.hub_id, h.hub_name
FROM hubs h
LEFT JOIN shipments s ON h.hub_id = s.origin_hub_id
WHERE s.shipment_id IS NULL;
