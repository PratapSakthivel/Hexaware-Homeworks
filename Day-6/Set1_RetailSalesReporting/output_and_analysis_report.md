# Set 1 – Retail Sales Reporting: Expected Results & Analysis

**Author:** Retail BI & Analytics Team  
**Database System:** MySQL 8.4 LTS  
**Schema:** `retail_sales_db`

---

## 1. Expected Result Sets for All 8 Queries

### Query 1: Top-5 Products by Revenue
```text
+------------+-------------------------------------+-------------+------------+-------------------+---------------------+
| product_id | product_name                        | category    | unit_price | total_units_sold  | total_gross_revenue |
+------------+-------------------------------------+-------------+------------+-------------------+---------------------+
|          5 | MOTORIZED STANDING DESK             | Furniture   | $520.00    |                 3 | $1,560.00           |
|          3 | ULTRA-WIDE 34-INCH MONITOR          | Electronics | $450.00    |                 2 | $900.00             |
|          1 | PRO WIRELESS HEADSET                | Electronics | $150.00    |                 3 | $450.00             |
|          4 | ERGONOMIC DESK CHAIR                | Furniture   | $220.00    |                 2 | $440.00             |
|          2 | MECHANICAL RGB KEYBOARD             | Electronics | $110.00    |                 4 | $440.00             |
+------------+-------------------------------------+-------------+------------+-------------------+---------------------+
```

### Query 2: Month-wise Sales Revenue
```text
+-------------+----------------+--------------+------------------+-----------------------+
| sales_month | month_name     | total_orders | total_items_sold | monthly_sales_revenue |
+-------------+----------------+--------------+------------------+-----------------------+
| 2026-09     | September 2026 |            4 |                6 | $1,480.00             |
| 2026-10     | October 2026   |            9 |               15 | $2,538.00             |
+-------------+----------------+--------------+------------------+-----------------------+
```

### Query 3: Customers with More Than 3 Orders (HAVING)
```text
+-------------+-----------------------+--------------------+-------------+----------------+
| customer_id | customer_profile      | email              | order_count | lifetime_spend |
+-------------+-----------------------+--------------------+-------------+----------------+
|           1 | Alice Johnson (New York) | alice.j@email.com|           4 |        1680.00 |
+-------------+-----------------------+--------------------+-------------+----------------+
```
*(Bob Smith has 3 orders; only Alice with 4 orders satisfies `HAVING COUNT(DISTINCT o.order_id) > 3`)*

### Query 4: Average Basket Value per City
```text
+---------------+-------------------+--------------------+------------------+
| city          | total_city_orders | total_city_revenue | avg_basket_value |
+---------------+-------------------+--------------------+------------------+
| San Francisco |                 1 |            1040.00 |          1040.00 |
| New York      |                 7 |            1880.00 |           268.57 |
| Chicago       |                 4 |             878.00 |           219.50 |
| Dallas        |                 1 |             220.00 |           220.00 |
+---------------+-------------------+--------------------+------------------+
```

### Query 5: Orders Without Payment (UNPAID or NULL Amount)
```text
+----------+----------------------+--------------+-----------------+--------+---------------------+-------------------+
| order_id | formatted_order_date | days_elapsed | customer_name   | city   | payment_status      | payment_status_display | order_amount_due  |
+----------+----------------------+--------------+-----------------+--------+---------------------+-------------------+
|      112 | 29-Oct-2026          |           15 | Fiona Gallagher | Dallas | UNPAID              | NO PAYMENT RECEIVED |            220.00 |
|      113 | 30-Oct-2026          |           14 | Charlie Brown   | New York| PENDING            | NO PAYMENT RECEIVED |             70.00 |
+----------+----------------------+--------------+-----------------+--------+---------------------+-------------------+
```

### Query 6: Customers with No Orders
```text
+-------------+---------------+---------+---------------------+-------------------+--------------------------+---------------------+
| customer_id | customer_name | city    | email               | registration_date | days_since_registration  | account_status      |
+-------------+---------------+---------+---------------------+-------------------+--------------------------+---------------------+
|           7 | George Clark  | Seattle | george.c@email.com  | 18-Jun-2026       |                      148 | INACTIVE / PROSPECT |
|           8 | Hannah Abbott | Seattle | hannah.a@email.com  | 22-Jul-2026       |                      114 | INACTIVE / PROSPECT |
+-------------+---------------+---------+---------------------+-------------------+--------------------------+---------------------+
```

### Query 7: Product-Category Revenue Share Percentage
```text
+----------------+-------------------------+----------------------+------------------+-------------------------+
| category       | distinct_products_count | total_quantity_sold  | category_revenue | revenue_percentage_share|
+----------------+-------------------------+----------------------+------------------+-------------------------+
| Furniture      |                       2 |                    5 |          2000.00 |                   49.78 |
| Electronics    |                       3 |                    9 |          1790.00 |                   44.55 |
| Home & Kitchen |                       1 |                    6 |           210.00 |                    5.23 |
| Groceries      |                       2 |                    3 |            18.00 |                    0.45 |
+----------------+-------------------------+----------------------+------------------+-------------------------+
```

### Query 8: Day with the Highest Sales
```text
+------------+--------------------------+--------------+------------------+-----------------------+
| order_date | full_date_description    | orders_count | total_items_sold | peak_day_sales_amount |
+------------+--------------------------+--------------+------------------+-----------------------+
| 2026-10-05 | Monday, 05 October 2026  |            1 |                2 |               1040.00 |
+------------+--------------------------+--------------+------------------+-----------------------+
```

---

## 2. NULL Behaviour Demonstration

SQL aggregate functions treat `NULL` values differently depending on their design:

```sql
SELECT 
    COUNT(*) AS total_rows_count_star,
    COUNT(payment_amount) AS count_payment_column,
    SUM(payment_amount) AS total_paid_sum,
    ROUND(AVG(payment_amount), 2) AS default_avg_ignores_null,
    ROUND(AVG(COALESCE(payment_amount, 0)), 2) AS true_avg_treating_null_zero
FROM orders;
```

### Expected Output:
```text
+------------------------+----------------------+----------------+---------------------------+---------------------------------+
| total_rows_count_star  | count_payment_column | total_paid_sum | default_avg_ignores_null  | true_avg_treating_null_zero     |
+------------------------+----------------------+----------------+---------------------------+---------------------------------+
|                     13 |                   11 |        3718.00 |                    338.00 |                          286.00 |
+------------------------+----------------------+----------------+---------------------------+---------------------------------+
```

### Core Analytical Takeaways:
1. **`COUNT(*)`**: Counts every row satisfying criteria regardless of whether column values are `NULL` ($13\text{ rows}$).
2. **`COUNT(column)`**: Excludes all `NULL` values; counts only non-null entries ($11\text{ rows}$).
3. **`SUM(column)`**: Silently ignores `NULL` entries without throwing a runtime error.
4. **`AVG(column)` Trap:** Standard `AVG(payment_amount)` calculates $\frac{\text{SUM}}{\text{COUNT(col)}} = \frac{3718}{11} = \$338.00$. If business logic requires unpaid orders to count as \$0, `AVG(COALESCE(payment_amount, 0))` must be used: $\frac{3718}{13} = \$286.00$.

---

## 3. Explaining the Difference Between WHERE and HAVING

| Operational Parameter | `WHERE` Clause | `HAVING` Clause |
| :--- | :--- | :--- |
| **Pipeline Stage** | Executes **before** grouping (`GROUP BY`). | Executes **after** grouping (`GROUP BY`). |
| **Filtering Level** | Filters **individual rows** in physical tables or join streams. | Filters **aggregated groups** or summarized summary rows. |
| **Aggregate Functions** | **Cannot** contain aggregate functions (`WHERE SUM(price) > 100` throws error). | **Can and usually does** contain aggregate functions (`HAVING COUNT(*) > 3`). |
| **Index Usage** | Can leverage B-Tree indexes to prune physical table scan. | Cannot utilize indexes directly; evaluates over grouped in-memory sets. |

### Concrete Query Example:
```sql
SELECT c.city, COUNT(DISTINCT o.order_id) AS orders_in_city, SUM(oi.quantity * p.unit_price) AS gross_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_date >= '2026-09-01'              -- Row filter: Only include orders from Sept 2026 onwards
GROUP BY c.city
HAVING SUM(oi.quantity * p.unit_price) > 500.00 -- Group filter: Prune cities with under $500 total revenue
ORDER BY gross_sales DESC;
```
- In this query, `WHERE` discards old historical rows before computing sums. Then `HAVING` evaluates the city totals, discarding cities like Dallas whose revenue was beneath \$500.
