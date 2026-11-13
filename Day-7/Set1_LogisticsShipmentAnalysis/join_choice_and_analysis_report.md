# Set 1 – Logistics Shipment Analysis: Join-Choice & Subquery Architecture

**Author:** Logistics Engineering & Freight Analytics Team  
**Database System:** MySQL 8.4 LTS  
**Schema:** `logistics_shipment_db`

---

## 1. Join-Choice Table for the 10 Business Questions

| Question # | Focus Area | Join Type / Construct Chosen | Technical Justification for Choice |
| :---: | :--- | :--- | :--- |
| **Q1** | Delayed Shipments ($>2$ days) with Carrier Names | **`INNER JOIN`** | Only shipments with verified carrier records must be returned; filtering eliminates unmatched rows. |
| **Q2** | Hubs with No Outbound Shipments | **`LEFT OUTER JOIN`** | Preserves all hubs regardless of activity; `WHERE s.shipment_id IS NULL` captures dormant hubs. |
| **Q3** | Employees and Supervisors Hierarchy | **`SELF JOIN (LEFT)`** | Connects `employees e` to `employees m` on `e.manager_id = m.employee_id`. Left join preserves the CEO/VP who has no manager. |
| **Q4** | Carriers & Total Volume | **`RIGHT OUTER JOIN`** | Evaluates carrier performance including newly signed carriers with zero shipments. |
| **Q5** | Customers Shipping to Every Hub | **`INNER JOIN + Relational Division`** | Matches customer shipments against total count of distinct hubs using `HAVING COUNT(DISTINCT) = (SELECT COUNT(*) FROM hubs)`. |
| **Q6** | Carriers with Delays Above Overall Avg | **`INNER JOIN + Correlated HAVING`** | Joins carrier performance data; subquery computes global baseline delay across all records. |
| **Q7** | Customers Using Express Tier | **`Correlated Subquery (EXISTS)`** | Short-circuits on first matching shipment without requiring duplicate rows or DISTINCT overhead. |
| **Q8** | Costs Higher than ANY Hub 3 Shipment | **`Subquery with ANY`** | Evaluates scalar comparison against the set of Hub 3 shipment costs ($> \text{ANY}$ equates to $> \text{MIN}$). |
| **Q9** | Costs Greater than ALL Economy Shipments | **`Subquery with ALL`** | Enforces that cost exceeds the absolute ceiling ($> \text{MAX}$) of the subquery result set. |
| **Q10** | Second-Highest Shipping Cost per Hub | **`Correlated Nested Subquery`** | Double-nested subquery calculates $\max(cost)$ strictly less than the hub maximum. |

---

## 2. Expected Results for the 10 Queries

### Q1: Shipments Delayed by $>2$ Days
```text
+-----------------+-----------------------+------------------------+----------------------+---------------+---------------+
| tracking_number | carrier_name          | promised_delivery_date | actual_delivery_date | delay_in_days | shipping_cost |
+-----------------+-----------------------+------------------------+----------------------+---------------+---------------+
| TRK-1001        | SwiftAir Express      | 2026-10-05             | 2026-10-09           |             4 |        450.00 |
| TRK-1002        | CrossCountry Freight  | 2026-10-08             | 2026-10-12           |             4 |        320.00 |
| TRK-1006        | CrossCountry Freight  | 2026-10-06             | 2026-10-10           |             4 |        480.00 |
| TRK-1008        | SwiftAir Express      | 2026-10-14             | 2026-10-18           |             4 |        550.00 |
| TRK-1010        | CrossCountry Freight  | 2026-10-22             | 2026-10-26           |             4 |        720.00 |
+-----------------+-----------------------+------------------------+----------------------+---------------+---------------+
```

### Q2: Hubs with No Outbound Shipments
```text
+--------+----------+------------------------------+-------+-------+-------------------------+
| hub_id | hub_code | hub_name                     | city  | state | outbound_shipment_count |
+--------+----------+------------------------------+-------+-------+-------------------------+
|      5 | HUB-MIA  | Sunshine Distribution Center | Miami | FL    |                       0 |
+--------+----------+------------------------------+-------+-------+-------------------------+
```

### Q3: Employees with Their Supervisors (Self Join)
```text
+-------------+--------------------+------------------------------+---------------------------+--------------------------+------------------------------+
| employee_id | employee_name      | employee_role                | assigned_hub              | supervisor_name          | supervisor_role              |
+-------------+--------------------+------------------------------+---------------------------+--------------------------+------------------------------+
|           1 | Victoria Stone     | VP Logistics Operations      | Midwest Gateway Hub       | TOP EXECUTIVE / BOARD    | N/A                          |
|           2 | Arthur Pendelton   | Regional Director Midwest    | Midwest Gateway Hub       | Victoria Stone           | VP Logistics Operations      |
|           4 | Carlos Gomez       | Regional Director East       | Metro East Terminal       | Victoria Stone           | VP Logistics Operations      |
|           3 | Beatrice Vance     | Hub Shift Supervisor         | Midwest Gateway Hub       | Arthur Pendelton         | Regional Director Midwest    |
|           6 | Edward Miller      | Fleet Supervisor             | Southern Central Terminal | Arthur Pendelton         | Regional Director Midwest    |
|           5 | Diana Prince       | Station Dispatcher           | Metro East Terminal       | Carlos Gomez             | Regional Director East       |
+-------------+--------------------+------------------------------+---------------------------+--------------------------+------------------------------+
```

### Q5: Customers Shipping to Every Hub
```text
+-------------+--------------------+---------------+------------------------+
| customer_id | customer_name      | customer_type | distinct_hubs_reached  |
+-------------+--------------------+---------------+------------------------+
|           1 | Apex Global Retail | Enterprise    |                      5 |
+-------------+--------------------+---------------+------------------------+
```

### Q10: Second-Highest Shipping Cost per Origin Hub
```text
+---------------+---------------------------+---------------------+
| origin_hub_id | hub_name                  | second_highest_cost |
+---------------+---------------------------+---------------------+
|             1 | Midwest Gateway Hub       |              450.00 |
|             2 | Metro East Terminal       |              210.00 |
|             3 | Southern Central Terminal |              420.00 |
|             4 | Bay Area Logistics Hub    |              390.00 |
+---------------+---------------------------+---------------------+
```

---

## 3. Subquery vs. Join Rewrites: Readability & Performance Analysis

### Pair 1: Customer Filtering
- **Subquery Form (`IN`):**
  ```sql
  SELECT customer_id, customer_name FROM customers 
  WHERE customer_id IN (SELECT DISTINCT customer_id FROM shipments WHERE shipping_cost > 500.00);
  ```
- **Join Form (`INNER JOIN`):**
  ```sql
  SELECT DISTINCT c.customer_id, c.customer_name
  FROM customers c
  INNER JOIN shipments s ON c.customer_id = s.customer_id
  WHERE s.shipping_cost > 500.00;
  ```
- **Evaluation:**
  - **Readability:** The `IN` subquery is more intuitive to human analysts because it mirrors natural language: *"Find customers whose IDs are in high-value shipments"*.
  - **Performance:** In MySQL 8.4, the cost-based optimizer transforms the `IN` subquery into a semi-join (`Semi-join Hash / B-Tree Lookup`), yielding identical execution plans to the `INNER JOIN`. On unindexed legacy databases, `INNER JOIN` is faster.

### Pair 2: Anti-Join (Hubs without Shipments)
- **Subquery Form (`NOT EXISTS`):**
  ```sql
  SELECT hub_id, hub_name FROM hubs h 
  WHERE NOT EXISTS (SELECT 1 FROM shipments s WHERE s.origin_hub_id = h.hub_id);
  ```
- **Join Form (`LEFT JOIN ... IS NULL`):**
  ```sql
  SELECT h.hub_id, h.hub_name FROM hubs h
  LEFT JOIN shipments s ON h.hub_id = s.origin_hub_id
  WHERE s.shipment_id IS NULL;
  ```
- **Evaluation:**
  - **Readability:** `NOT EXISTS` is semantically clearer; it directly expresses the business condition (*no matching record exists*).
  - **Performance:** Both leverage index null-filtering. However, `NOT EXISTS` short-circuits as soon as a single child row is found, avoiding building full outer join streams in memory.
