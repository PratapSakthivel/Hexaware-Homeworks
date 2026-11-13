# Set 3 – Telecom Usage and Billing: Expected Results & Aggregation Analysis

**Author:** Telecom Revenue Assurance & BI Team  
**Database System:** MySQL 8.4 LTS  
**Schema:** `telecom_billing_db`

---

## 1. Expected Result Sets for All 8 Queries

### Query 1: Total Call Minutes per Plan
```text
+---------+--------------------------+----------------+--------------------+----------------------+--------------------------+----------------------+
| plan_id | plan_name                | monthly_rental | free_call_minutes  | enrolled_subscribers | total_call_minutes_logged| avg_minutes_per_call |
+---------+--------------------------+----------------+--------------------+----------------------+--------------------------+----------------------+
|       3 | Platinum Unlimited 799   |         799.00 |               3000 |                    2 |                      970 |                485.0 |
|       4 | Enterprise Infinity 1299 |        1299.00 |              10000 |                    1 |                      890 |                890.0 |
|       2 | Gold Max 499             |         499.00 |               1000 |                    4 |                      850 |                212.5 |
|       1 | Silver Freedom 299       |         299.00 |                300 |                    3 |                      205 |                102.5 |
+---------+--------------------------+----------------+--------------------+----------------------+--------------------------+----------------------+
```

### Query 2: Subscribers Exceeding Their Plan Data Limit (HAVING)
```text
+---------------+--------------+-----------------+-------------+--------------------+----------------+---------------------+-------------------+
| subscriber_id | phone_number | subscriber_name | circle      | plan_name          | plan_quota_gb  | actual_data_used_gb | overage_data_gb   |
+---------------+--------------+-----------------+-------------+--------------------+----------------+---------------------+-------------------+
|             1 | 9820011221   | Rohan Sharma    | Maharashtra | Gold Max 499       |             30 |               34.18 |              4.18 |
|             3 | 9810022331   | Amit Verma      | Delhi       | Silver Freedom 299 |             10 |               12.21 |              2.21 |
+---------------+--------------+-----------------+-------------+--------------------+----------------+---------------------+-------------------+
```
*(Automated billing action: Generate data top-up alerts and calculate overage billing rate of \$0.02 per MB)*

### Query 3: Month-wise Billed Telecom Revenue
```text
+----------------+----------------+--------------------------+----------------------+-----------------------+
| billing_period | month_title    | total_invoices_generated | total_billed_revenue | average_invoice_value |
+----------------+----------------+--------------------------+----------------------+-----------------------+
| 2026-09        | September 2026 |                        2 | INR 1,298.00         | INR 649.00            |
| 2026-10        | October 2026   |                        9 | INR 5,327.50         | INR 591.94            |
+----------------+----------------+--------------------------+----------------------+-----------------------+
```

### Query 4: Invoices Overdue by More than 15 Days (as of Nov 13, 2026)
```text
+------------------+-----------------+----------------+-------------+--------------------+--------------+---------------------+---------------------+
| invoice_number   | subscriber_name | contact_number | circle      | formatted_due_date | days_overdue | outstanding_balance | collection_priority |
+------------------+-----------------+----------------+-------------+--------------------+--------------+---------------------+---------------------+
| INV-2026-10-001  | Rohan Sharma    | +91-9820011221 | Maharashtra | 20-Oct-2026        |           24 | INR 589.50          | SEVERELY OVERDUE    |
| INV-2026-10-003  | Amit Verma      | +91-9810022331 | Delhi       | 20-Oct-2026        |           24 | INR 345.00          | SEVERELY OVERDUE    |
| INV-2026-10-005  | Karthik Raja    | +91-9845033441 | Karnataka   | 20-Oct-2026        |           24 | INR 499.00          | SEVERELY OVERDUE    |
| INV-2026-10-009  | Vikram Seth     | +91-9840044553 | Delhi       | 28-Oct-2026        |           16 | INR 299.00          | SEVERELY OVERDUE    |
+------------------+-----------------+----------------+-------------+--------------------+--------------+---------------------+---------------------+
```

### Query 5: Subscribers with No Usage Records (Dormant SIMs)
```text
+---------------+-----------------+--------------+-------------+--------------------+--------------+------------------------+
| subscriber_id | subscriber_name | phone_number | circle      | plan_name          | activated_on | days_active_zero_usage |
+---------------+-----------------+--------------+-------------+--------------------+--------------+------------------------+
|             9 | Vikram Seth     | 9840044553   | Delhi       | Silver Freedom 299 | 01-Sep-2026  |                     73 |
|            10 | Zoya Akhtar     | 9820011229   | Maharashtra | Gold Max 499       | 15-Sep-2026  |                     59 |
+---------------+-----------------+--------------+-------------+--------------------+--------------+------------------------+
```

### Query 6: Average Revenue Per User (ARPU) by Circle
```text
+-------------+-------------------+----------------------+-------------+
| circle      | total_subscribers | total_circle_revenue | arpu_amount |
+-------------+-------------------+----------------------+-------------+
| Tamil Nadu  |                 2 |              1598.00 |      799.00 |
| Maharashtra |                 3 |              2686.50 |      895.50 |
| Karnataka   |                 2 |              1298.00 |      649.00 |
| Delhi       |                 3 |              1143.00 |      381.00 |
+-------------+-------------------+----------------------+-------------+
```

### Query 7: Plan Popularity & Market Share
```text
+---------+--------------------------+------------------+----------------------+--------------------+
| plan_id | plan_name                | subscriber_count | subscriber_share_pct | total_plan_revenue |
+---------+--------------------------+------------------+----------------------+--------------------+
|       2 | Gold Max 499             |                4 |                 40.0 |            1587.50 |
|       1 | Silver Freedom 299       |                3 |                 30.0 |             943.00 |
|       3 | Platinum Unlimited 799   |                2 |                 20.0 |            2397.00 |
|       4 | Enterprise Infinity 1299 |                1 |                 10.0 |            1299.00 |
+---------+--------------------------+------------------+----------------------+--------------------+
```

### Query 8: Top Data Consumers Across Network
```text
+---------------+-----------------+--------------+-------------+--------------------------+------------------------+-------------------+
| subscriber_id | subscriber_name | phone_number | circle      | plan_name                | total_data_consumed_gb | total_voice_minutes|
+---------------+-----------------+--------------+-------------+--------------------------+------------------------+-------------------+
|             7 | Suresh Kumar    | 9840044551   | Tamil Nadu  | Enterprise Infinity 1299 |                 107.42 |               890 |
|             6 | Deepa Nair      | 9845033442   | Karnataka   | Platinum Unlimited 799   |                  56.64 |               520 |
|             2 | Priya Patel     | 9820011222   | Maharashtra | Platinum Unlimited 799   |                  41.02 |               450 |
|             1 | Rohan Sharma    | 9820011221   | Maharashtra | Gold Max 499             |                  34.18 |               360 |
|             5 | Karthik Raja    | 9845033441   | Karnataka   | Gold Max 499             |                  24.41 |               310 |
|             4 | Neha Gupta      | 9810022332   | Delhi       | Gold Max 499             |                  17.58 |               180 |
|             3 | Amit Verma      | 9810022331   | Delhi       | Silver Freedom 299       |                  12.21 |               110 |
|             8 | Ananya Iyer     | 9840044552   | Tamil Nadu  | Silver Freedom 299       |                   4.39 |                95 |
+---------------+-----------------+--------------+-------------+--------------------------+------------------------+-------------------+
```

---

## 2. NULL Handling Demonstration: `IFNULL` & `COALESCE`

When performing outer joins where child tables have no records (e.g. dormant subscribers Vikram Seth and Zoya Akhtar):

```sql
SELECT 
    s.subscriber_name,
    COUNT(cr.call_id) AS calls_count,
    SUM(cr.duration_minutes) AS raw_sum_null_if_empty,
    IFNULL(SUM(cr.duration_minutes), 0) AS safe_sum_with_ifnull,
    COALESCE(SUM(cr.duration_minutes), 0) AS safe_sum_with_coalesce
FROM subscribers s
LEFT JOIN call_records cr ON s.subscriber_id = cr.subscriber_id
GROUP BY s.subscriber_id, s.subscriber_name;
```

### Result:
```text
+-----------------+-------------+------------------------+----------------------+------------------------+
| subscriber_name | calls_count | raw_sum_null_if_empty  | safe_sum_with_ifnull | safe_sum_with_coalesce |
+-----------------+-------------+------------------------+----------------------+------------------------+
| Vikram Seth     |           0 |                   NULL |                    0 |                      0 |
| Zoya Akhtar     |           0 |                   NULL |                    0 |                      0 |
| Ananya Iyer     |           1 |                     95 |                   95 |                     95 |
| Amit Verma      |           1 |                    110 |                  110 |                    110 |
+-----------------+-------------+------------------------+----------------------+------------------------+
```

### Architectural Takeaway:
Without `COALESCE()` or `IFNULL()`, downstream billing and report calculation engines encounter `NULL` arithmetic ($100 + \text{NULL} = \text{NULL}$), breaking financial ledgers. Wrapping aggregates in `COALESCE` ensures graceful zero-fallback.
