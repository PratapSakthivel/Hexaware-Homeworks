# Set 2 – Insurance Policy Reporting: Expected Results & Joins Architecture

**Author:** Actuarial & Underwriting BI Team  
**Database System:** MySQL 8.4 LTS  
**Schema:** `insurance_policy_db`

---

## 1. Expected Result Sets for All 8 Queries

### Query 1: Policies Expiring in Next 30 Days (from Nov 13, 2026)
```text
+-----------+----------------------+------------------+----------+-----------------------------+-----------------+-----------------------+----------------+
| policy_id | masked_policy_number | customer_name    | city     | product_name                | expiration_date | days_until_expiration | annual_premium |
+-----------+----------------------+------------------+----------+-----------------------------+-----------------+-----------------------+----------------+
|       101 | POL-MTR-****         | Marcus Aurelius  | New York | Comprehensive Motor Shield  | 2026-11-20      |                     7 | $1,200.00      |
|       102 | POL-HLT-****         | Marcus Aurelius  | New York | Global Platinum Health Care | 2026-11-28      |                    15 | $2,400.00      |
|       103 | POL-MTR-****         | Eleanor Vance    | Chicago  | Comprehensive Motor Shield  | 2026-12-05      |                    22 | $1,450.00      |
+-----------+----------------------+------------------+----------+-----------------------------+-----------------+-----------------------+----------------+
```

### Query 2: Premium Written per Product
```text
+------------+--------------+-----------------------------+------------------+----------------------+------------------------+--------------------+
| product_id | product_code | product_name                | line_of_business | total_policies_count | total_premium_written  | avg_policy_premium |
+------------+--------------+-----------------------------+------------------+----------------------+------------------------+--------------------+
|          4 | PRD-PRP-04   | Commercial Property Guard   | Property         |                    2 |               20500.00 |           10250.00 |
|          2 | PRD-HLT-02   | Global Platinum Health Care | Health           |                    3 |                8800.00 |            2933.33 |
|          3 | PRD-LIF-03   | Term Life Secure 30Y        | Life             |                    2 |                8000.00 |            4000.00 |
|          1 | PRD-MTR-01   | Comprehensive Motor Shield  | Motor            |                    3 |                4750.00 |            1583.33 |
+------------+--------------+-----------------------------+------------------+----------------------+------------------------+--------------------+
```

### Query 3: Customers with More than One Active Policy (HAVING)
```text
+-------------+-----------------+----------+--------------------+---------------------+--------------------------+
| customer_id | customer_name   | city     | email              | active_policy_count | combined_annual_premium  |
+-------------+-----------------+----------+--------------------+---------------------+--------------------------+
|           5 | Bruce Wayne     | Chicago  | bruce.w@email.com  |                   3 |                 17700.00 |
|           1 | Marcus Aurelius | New York | marcus.a@email.com |                   2 |                  3600.00 |
|           4 | Sarah Connor    | Dallas   | sarah.c@email.com  |                   2 |                 11300.00 |
+-------------+-----------------+----------+--------------------+---------------------+--------------------------+
```

### Query 4: Claim Ratio per Product
```text
+------------+-----------------------------+------------------+-------------------------+-------------------+----------------------+
| product_id | product_name                | line_of_business | total_premium_collected | total_claims_paid | claim_loss_ratio_pct |
+------------+-----------------------------+------------------+-------------------------+-------------------+----------------------+
|          1 | Comprehensive Motor Shield  | Motor            |                 4750.00 |           3500.00 |                73.68 |
|          2 | Global Platinum Health Care | Health           |                 8800.00 |           1000.00 |                11.36 |
|          4 | Commercial Property Guard   | Property         |                20500.00 |           1500.00 |                 7.32 |
|          3 | Term Life Secure 30Y        | Life             |                 8000.00 |              0.00 |                 0.00 |
+------------+-----------------------------+------------------+-------------------------+-------------------+----------------------+
```

### Query 5: Policies Without Claims (Clean Underwriting)
```text
+-----------+------------------+---------------------+-----------------------------+------------+------------+----------------------+
| policy_id | masked_policy_no | customer_name       | product_name                | start_date | end_date   | safe_premium_earned  |
+-----------+------------------+---------------------+-----------------------------+------------+------------+----------------------+
|       108 | POL-PRP-****     | Bruce Wayne         | Commercial Property Guard   | 2026-10-05 | 2027-10-05 | $12,000.00           |
|       109 | POL-LIF-****     | Diana Prince        | Term Life Secure 30Y        | 2026-10-15 | 2027-10-15 | $4,200.00            |
|       104 | POL-LIF-****     | Victor Frankenstein | Term Life Secure 30Y        | 2026-01-15 | 2027-01-15 | $3,800.00            |
|       110 | POL-HLT-****     | Sarah Connor        | Global Platinum Health Care | 2026-10-22 | 2027-10-22 | $2,800.00            |
|       102 | POL-HLT-****     | Marcus Aurelius     | Global Platinum Health Care | 2025-11-28 | 2026-11-28 | $2,400.00            |
|       106 | POL-MTR-****     | Bruce Wayne         | Comprehensive Motor Shield  | 2026-08-01 | 2027-08-01 | $2,100.00            |
|       103 | POL-MTR-****     | Eleanor Vance       | Comprehensive Motor Shield  | 2025-12-05 | 2026-12-05 | $1,450.00            |
+-----------+------------------+---------------------+-----------------------------+------------+------------+----------------------+
```

### Query 6: Average Premium by Age Band
```text
+------------------------------+-------------------------+-----------------+-----------------------+
| age_band                     | total_policies_in_band  | average_premium | total_premium_by_band |
+------------------------------+-------------------------+-----------------+-----------------------+
| 36-45 Years (Mid-Career)     |                       2 |         5650.00 |              11300.00 |
| 46-60 Years (Mature Families)|                       4 |         5375.00 |              21500.00 |
| 26-35 Years (Early Career)   |                       3 |         2600.00 |               7800.00 |
| 18-25 Years (Young Adults)   |                       1 |         1450.00 |               1450.00 |
+------------------------------+-------------------------+-----------------+-----------------------+
```

### Query 7: Monthly New Policies Written
```text
+----------------------+----------------+---------------------+----------------------+---------------+
| policy_booking_month | month_name     | new_policies_issued | new_business_premium | avg_deal_size |
+----------------------+----------------+---------------------+----------------------+---------------+
| 2025-11              | November 2025  |                   2 |              3600.00 |       1800.00 |
| 2025-12              | December 2025  |                   1 |              1450.00 |       1450.00 |
| 2026-01              | January 2026   |                   1 |              3800.00 |       3800.00 |
| 2026-05              | May 2026       |                   1 |              8500.00 |       8500.00 |
| 2026-08              | August 2026    |                   1 |              2100.00 |       2100.00 |
| 2026-09              | September 2026 |                   1 |              3600.00 |       3600.00 |
| 2026-10              | October 2026   |                   3 |             19000.00 |       6333.33 |
+----------------------+----------------+---------------------+----------------------+---------------+
```

### Query 8: Top-5 Agents by Total Premium Written
```text
+----------+------------+-------------------+-----------+----------------------+-------------------------+
| agent_id | agent_code | agent_name        | region    | total_policies_sold  | total_premium_generated |
+----------+------------+-------------------+-----------+----------------------+-------------------------+
|        5 | AGT-005    | Alfred Pennyworth | Northeast |                    3 |                17700.00 |
|        4 | AGT-004    | Lucius Fox        | South     |                    1 |                 8500.00 |
|        1 | AGT-001    | James Gordon      | Northeast |                    3 |                 7800.00 |
|        2 | AGT-002    | Harvey Dent       | Midwest   |                    2 |                 4250.00 |
|        3 | AGT-003    | Rachel Dawes      | West Coast|                    1 |                 3800.00 |
+----------+------------+-------------------+-----------+----------------------+-------------------------+
```

---

## 2. High Loss-Ratio Products (HAVING > 60%)
```text
+------------+----------------------------+-----------------------+-------------------+------------------------+
| product_id | product_name               | total_premium_written | total_claims_paid | claim_ratio_percentage |
+------------+----------------------------+-----------------------+-------------------+------------------------+
|          1 | Comprehensive Motor Shield |               4750.00 |           3500.00 |                  73.68 |
+------------+----------------------------+-----------------------+-------------------+------------------------+
```
*(Underwriting action required: Review motor insurance premium rates or deductibles due to loss ratio exceeding statutory target of 60%)*

---

## 3. Justification of Join Types Used

| Join Type | Business Scenario Applied | Technical Justification |
| :--- | :--- | :--- |
| **`INNER JOIN`** | `policies p JOIN customers c ON p.customer_id = c.customer_id` | **Strict Referential Relationship:** An insurance policy cannot exist without a valid policyholder. We only want rows where both customer and policy exist. |
| **`LEFT OUTER JOIN`** | `policies p LEFT JOIN claims c ON p.policy_id = c.policy_id` | **Optional Event Relationship:** Most policies will never experience a loss incident. An INNER JOIN would drop all safe policies, distorting total premium. A LEFT JOIN preserves 100% of policies while matching claims where present. |
| **`CROSS JOIN`** | `products p CROSS JOIN (SELECT DISTINCT region FROM agents) r` | **Cartesian Coverage Matrix:** Generates all theoretical combinations of insurance products against geographic sales regions to evaluate product availability gaps. |
