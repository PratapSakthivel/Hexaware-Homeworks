# Set 3: Retail Inventory Reservation – ACID Explanation & Analytical Reports

## Overview
This document delivers the comprehensive technical analysis for **Set 3 – Retail Inventory Reservation** under **MySQL 8.4 LTS**. It details the expected tabular outputs for inventory reservation, window function reporting (`ROW_NUMBER`, `LEAD`, `LAG`), provides a rigorous breakdown of each **ACID property** with real scenarios, and proves how a non-transactional engine (such as MyISAM or uncommitted autocommit) irreparably compromises data integrity.

---

## 1. Expected Results & Query Execution Analysis

### Task 1: Inventory Reservation & Insufficient Stock Rollback Proof
- **Initial State for Product 6 (`Robot Vacuum Cleaner`):** `stock_quantity = 2`.
- **Test 1A (Order `ORD-2026-1001` - Quantity 1):**
  - Stored procedure executes: locks row via `SELECT ... FOR UPDATE`, checks $2 \ge 1$, updates stock to $1$, creates order header and item line, and commits.
  - Result: `SUCCESS: Order ORD-2026-1001 confirmed. Stock reserved: 1 units. New stock: 1`.
- **Test 1B (Order `ORD-2026-1002` - Quantity 5):**
  - Stored procedure executes: checks $1 < 5$.
  - Result: `FAILED_INSUFFICIENT_STOCK: Requested 5 units, but only 1 available. Transaction aborted.`.
  - Verification: Rollback is triggered; stock remains exactly `1`; zero orphan records exist in `orders` or `order_items`.

---

### Task 2: Correlated Subquery – Products Below Category Average Stock
Identifies inventory items requiring immediate replenishment because their on-hand count is lower than their category peers.
#### Expected Tabular Output:
```
+------------+--------------+-----------------------+-----------------+----------------+--------------------+---------------+
| product_id | sku          | product_name          | category_name   | stock_quantity | category_avg_stock | stock_deficit |
+------------+--------------+-----------------------+-----------------+----------------+--------------------+---------------+
|          7 | APPR-JKT-301 | Winter Down Jacket    | Apparel         |             25 |               27.5 |           2.5 |
|          1 | ELEC-LAP-101 | UltraBook Pro 14      | Electronics     |             15 |               14.3 |          -0.7 | -- (Filtered out by WHERE)
|          2 | ELEC-PHN-102 | Smartphone Ultra 5G   | Electronics     |              8 |               14.3 |           6.3 |
|          6 | APPL-VAC-203 | Robot Vacuum Cleaner  | Home Appliances |              1 |                6.0 |           5.0 |
|          4 | APPL-REF-201 | Double Door Refrig... | Home Appliances |              5 |                6.0 |           1.0 |
+------------+--------------+-----------------------+-----------------+----------------+--------------------+---------------+
```
*Filter applied:*
- In **Electronics** (avg: 14.3 units): Product 2 (`Smartphone Ultra 5G`, stock 8) is flagged with a 6.3 deficit.
- In **Home Appliances** (avg: 6.0 units): Product 6 (`Robot Vacuum`, stock 1) and Product 4 (`Refrigerator`, stock 5) are flagged.
- In **Apparel** (avg: 27.5 units): Product 7 (`Winter Down Jacket`, stock 25) is flagged.

---

### Task 3: Top 3 Products by Sales within Category (CTE + `ROW_NUMBER()`)
#### Expected Tabular Output:
```
+-----------------+------------+--------------------------+--------------+----------+------------------+---------------------+
| category_name   | sales_rank | product_name             | sku          | price    | total_units_sold | total_sales_revenue |
+-----------------+------------+--------------------------+--------------+----------+------------------+---------------------+
| Apparel         |          1 | Winter Down Jacket       | APPR-JKT-301 |  6500.00 |              125 |           812500.00 |
| Apparel         |          2 | Performance Running Shoe | APPR-SHS-302 |  4200.00 |              140 |           588000.00 |
| Electronics     |          1 | Smartphone Ultra 5G      | ELEC-PHN-102 | 45000.00 |              115 |          5175000.00 |
| Electronics     |          2 | UltraBook Pro 14         | ELEC-LAP-101 | 75000.00 |               55 |          4125000.00 |
| Electronics     |          3 | Pro Tablet 11-inch       | ELEC-TAB-103 | 32000.00 |               51 |          1632000.00 |
| Home Appliances |          1 | Double Door Refrigerator | APPL-REF-201 | 38000.00 |               32 |          1216000.00 |
| Home Appliances |          2 | Convection Microwave     | APPL-MIC-202 | 12500.00 |               60 |           750000.00 |
| Home Appliances |          3 | Robot Vacuum Cleaner     | APPL-VAC-203 | 24000.00 |               21 |           504000.00 |
+-----------------+------------+--------------------------+--------------+----------+------------------+---------------------+
```

---

### Task 4: Month-on-Month Sales Growth using `LEAD()` and `LAG()`
#### Expected Tabular Output (Sample):
```
+--------------------------+---------------+----------------+-----------------------+--------------------+--------------------+---------------+------------------------------+
| product_name             | category_name | month_name     | current_month_revenue | prev_month_revenue | mom_revenue_growth | mom_growth_pct| upcoming_month_projection    |
+--------------------------+---------------+----------------+-----------------------+--------------------+--------------------+---------------+------------------------------+
| UltraBook Pro 14         | Electronics   | August 2026    |             900000.00 |               NULL |               NULL |          NULL |                   1350000.00 |
| UltraBook Pro 14         | Electronics   | September 2026 |            1350000.00 |          900000.00 |          450000.00 |         50.00 |                   1875000.00 |
| UltraBook Pro 14         | Electronics   | October 2026   |            1875000.00 |         1350000.00 |          525000.00 |         38.89 |                         NULL |
| Winter Down Jacket       | Apparel       | August 2026    |              65000.00 |               NULL |               NULL |          NULL |                    227500.00 |
| Winter Down Jacket       | Apparel       | September 2026 |             227500.00 |           65000.00 |          162500.00 |        250.00 |                    520000.00 |
| Winter Down Jacket       | Apparel       | October 2026   |             520000.00 |          227500.00 |          292500.00 |        128.57 |                         NULL |
+--------------------------+---------------+----------------+-----------------------+--------------------+--------------------+---------------+------------------------------+
```
*Insight:* `Winter Down Jacket` exhibited a dramatic 250% surge from August to September, anticipating the peak winter retail season.

---

## 2. Comprehensive ACID Explanation in the Context of Retail Inventory Reservation

The ACID model guarantees the validity of database operations even in the event of hardware crashes, network partitions, power outages, or concurrent conflicts.

### 1. Atomicity (All or Nothing)
- **Concrete Retail Example:** An order reservation consists of three discrete operations:
  1. `UPDATE products SET stock_quantity = stock_quantity - 2 WHERE product_id = 6;`
  2. `INSERT INTO orders (order_number, customer_id, total_amount, ...) VALUES ('ORD-999', 1, 48000.00, ...);`
  3. `INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total) VALUES (LAST_INSERT_ID(), 6, 2, 24000.00, 48000.00);`
- **Guarantee:** If the server loses power or step 3 encounters a foreign key constraint violation, InnoDB uses the **Undo Log** to roll back steps 1 and 2 completely. The inventory count is never decremented unless the order and its lines are permanently recorded.

### 2. Consistency (State Invariants & Constraints)
- **Concrete Retail Example:**
  - Table constraint: `CONSTRAINT chk_non_negative_stock CHECK (stock_quantity >= 0)`.
  - Financial integrity: `orders.total_amount` must equal $\sum (\text{order\_items.quantity} \times \text{unit\_price})$.
- **Guarantee:** A transaction cannot leave the database in an invalid state. If an order attempts to reserve 10 items when only 4 exist, the check constraint or procedure logic triggers a rollback, preventing negative stock. The database transitions only from one valid state to another.

### 3. Isolation (Concurrency Independence)
- **Concrete Retail Example:** Two shoppers (Customer A and Customer B) concurrently checkout the last unit of a promotional laptop (`stock_quantity = 1`).
- **Guarantee:** Under `REPEATABLE READ` or pessimistic `SELECT ... FOR UPDATE`, Customer A’s transaction acquires an exclusive row lock. Customer B’s transaction is blocked until Customer A commits or rolls back. Customer B never reads a partial "in-flight" decrement, preventing ghost stock allocations and double-selling.

### 4. Durability (Survivability of Committed Data)
- **Concrete Retail Example:** The payment gateway notifies the application that Customer A’s payment succeeded. The transaction issues `COMMIT;`.
- **Guarantee:** InnoDB writes the transaction modifications to the **Redo Log (`ib_logfile0`)** and flushes it to non-volatile disk according to `innodb_flush_log_at_trx_commit = 1`. Even if the database host suffers a sudden total power failure 1 millisecond after the commit acknowledgment, upon reboot InnoDB executes crash recovery via the redo log, ensuring the reserved order and updated stock are 100% preserved.

---

## 3. Case Demonstration: Where a Non-Transactional Design Breaks ACID

### Scenario: The MyISAM or Unchecked Autocommit Failure
Consider what happens if the e-commerce inventory system is designed using a non-transactional storage engine like **MyISAM** (or uncommitted auto-committed scripts without exception handlers).

#### The Workflow Failure:
```sql
-- Step 1: Stock is decremented immediately (MyISAM commits per statement!)
UPDATE products SET stock_quantity = stock_quantity - 2 WHERE product_id = 6;
-- (Disk updated immediately: stock is now 0)

-- Step 2: Order header inserted
INSERT INTO orders (order_number, customer_id, total_amount) VALUES ('ORD-FAIL-01', 2, 48000.00);

-- Step 3: Order item insertion fails! (e.g., Disk full, out of memory, or FK syntax error)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total) 
VALUES (99999, 6, 2, 24000.00, 48000.00); 
-- *** ERROR OCCURS HERE ***
```

#### Why it Breaks ACID in Non-Transactional Systems:
1. **Atomicity Destroyed:** MyISAM does not possess undo logs. When step 3 throws an error, MyISAM cannot issue a `ROLLBACK`. Step 1 and Step 2 remain permanently etched into the disk.
2. **Consistency Destroyed:** The warehouse has lost 2 units from inventory (`stock_quantity` decremented), but the order contains zero line items. An orphan order exists that warehouse fulfillment workers cannot pick or pack, and inventory audit reconciliation displays an unexplained phantom shortage.
3. **Isolation Destroyed:** In MyISAM, table-level locking is used instead of row-level locking. While the table is locked, all other shoppers attempting to browse or purchase any product in the entire catalog are blocked, degrading web portal throughput.
4. **Conclusion:** High-reliability financial and inventory platforms strictly require **InnoDB ACID transactions** with row-level pessimistic locking (`SELECT ... FOR UPDATE`) and explicit rollback handlers.
