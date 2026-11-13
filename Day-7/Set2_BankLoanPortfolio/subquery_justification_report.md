# Set 2 – Bank Loan Portfolio: Subquery Justifications & Risk Architecture

**Author:** Risk Analytics & Credit Modeling Team  
**Database System:** MySQL 8.4 LTS  
**Schema:** `bank_loans_db`

---

## 1. Justification Note for Joins and Subqueries

| Query # | Problem Solved | Construct Used | Technical Justification |
| :---: | :--- | :--- | :--- |
| **Q1** | Loans Overdue by $>3$ Instalments | **`INNER JOIN`** | Required mandatory links across `loans`, `customers`, and `branches` where overdue filter is strictly applied. |
| **Q2** | Customers with Multi-Branch Loans | **`INNER JOIN + GROUP BY / HAVING`** | Aggregates branch exposure; `HAVING COUNT(DISTINCT l.branch_id) > 1` identifies systemic multi-branch borrower concentration. |
| **Q3** | Guarantors who are also Borrowers | **`SELF / DUAL JOIN`** | Connects `guarantors` back to `customers` and joins against `loans` to unearth circular credit risk where a guarantor is encumbered by their own debt. |
| **Q4** | Branches with Zero Loans | **`LEFT OUTER JOIN`** | Preserves all branch rows; `COUNT(l.loan_id) = 0` detects newly established or dormant branches. |
| **Q5** | Exposure Exceeding Branch Average | **`Correlated Subquery in HAVING`** | Evaluates customer loan totals against dynamically calculated branch averages for that specific `branch_id`. |
| **Q6** | Delinquent Loans (No Payment in 60 Days) | **`NOT EXISTS Subquery`** | Semi-join anti-check; stops as soon as a recent payment is discovered. Outperforms `NOT IN` when handling potential null sets. |
| **Q7** | Loans Above Bank-Wide Mean | **`Uncorrelated Scalar Subquery`** | Subquery computes a single static bank-wide mean value once; outer query performs direct comparison. |
| **Q8** | Loans with Backed Guarantors | **`EXISTS Subquery`** | Validates presence of guarantor rows without generating redundant duplicated result sets. |
| **Q9** | Branches with Peak Loans Above Branch Max Average | **`Nested Derived Table Subquery`** | Inner derived table computes maximum loan per branch; parent computes average of those maximums; outer filters branches exceeding that benchmark. |
| **Q10** | Repayment Ratio vs Principal | **`LEFT OUTER JOIN + COALESCE`** | Preserves loans that have had zero repayments to date, preventing division errors or dropped loans. |

---

## 2. Expected Results for the 10 Queries

### Q1: Loans Overdue by $>3$ Instalments (High Default Risk)
```text
+-------------+---------------+--------------------------------+-------------+---------------------+-------------+
| loan_number | customer_name | branch_name                    | loan_amount | overdue_instalments | loan_status |
+-------------+---------------+--------------------------------+-------------+---------------------+-------------+
| LN-2026-005 | Tony Soprano  | Manhattan Flagship Branch      |  1200000.00 |                   6 | ACTIVE      |
| LN-2026-004 | Walter White  | Dallas Uptown Branch           |   320000.00 |                   5 | ACTIVE      |
| LN-2026-003 | Thomas Shelby | Chicago Loop Commercial Branch |   600000.00 |                   4 | ACTIVE      |
+-------------+---------------+--------------------------------+-------------+---------------------+-------------+
```

### Q2: Multi-Branch Borrowers
```text
+-------------+------------------+----------------------+--------------------------------------------------------------+-----------------------+
| customer_id | customer_name    | distinct_branch_count| borrowing_branches                                           | total_borrowed_amount |
+-------------+------------------+----------------------+--------------------------------------------------------------+-----------------------+
|           1 | Michael Corleone |                    2 | Manhattan Flagship Branch | Chicago Loop Commercial Branch   |            1300000.00 |
+-------------+------------------+----------------------+--------------------------------------------------------------+-----------------------+
```

### Q3: Circular Guarantor-Borrower Risk (Self Join)
```text
+--------------+-------------------------------+-------------------+-------------------+-----------------+-----------------------+-----------------------------+-----------------------------+
| guarantor_id | guarantor_and_borrower_name   | guaranteed_amount | relationship      | loan_guaranteed | primary_borrower_name | guarantor_own_loan_number   | guarantor_own_loan_amount   |
+--------------+-------------------------------+-------------------+-------------------+-----------------+-----------------------+-----------------------------+-----------------------------+
|            1 | Michael Corleone              |         300000.00 | Business Partner  | LN-2026-003     | Thomas Shelby         | LN-2026-001                 |                   850000.00 |
|            1 | Michael Corleone              |         300000.00 | Business Partner  | LN-2026-003     | Thomas Shelby         | LN-2026-002                 |                   450000.00 |
|            2 | Thomas Shelby                 |         160000.00 | Associate         | LN-2026-004     | Walter White          | LN-2026-003                 |                   600000.00 |
+--------------+-------------------------------+-------------------+-------------------+-----------------+-----------------------+-----------------------------+-----------------------------+
```
*(Credit Warning: Corleone guarantees Shelby, while Shelby has 4 overdue instalments and guarantees White who has 5 overdue instalments!)*

### Q4: Branches with No Disbursed Loans
```text
+-----------+-----------------------------+-------+-------------------+
| branch_id | branch_name                 | city  | total_loans_count |
+-----------+-----------------------------+-------+-------------------+
|         5 | Miami Beach Private Branch  | Miami |                 0 |
+-----------+-----------------------------+-------+-------------------+
```

### Q6: Delinquent Borrowers (No Repayment in Last 60 Days)
```text
+-------------+---------------+-------------+-------------+----------------+
| customer_id | customer_name | loan_number | loan_amount | disbursed_date |
+-------------+---------------+-------------+-------------+----------------+
|           4 | Tony Soprano  | LN-2026-005 |  1200000.00 | 2025-11-10     |
|           2 | Thomas Shelby | LN-2026-003 |   600000.00 | 2026-02-10     |
|           3 | Walter White  | LN-2026-004 |   320000.00 | 2026-04-05     |
|           4 | Tony Soprano  | LN-2026-009 |   250000.00 | 2026-08-30     |
+-------------+---------------+-------------+-------------+----------------+
```

### Q9: Branches with Maximum Loan Greater than Average of Branch Maximums
- Branch 1 Max: \$1,200,000 (Soprano)
- Branch 2 Max: \$1,500,000 (Bruce Wayne)
- Branch 3 Max: \$280,000 (Gilbert)
- Branch 4 Max: \$320,000 (White)
- Average of branch maximums: $\frac{1200000 + 1500000 + 280000 + 320000}{4} = \$825,000.00$.
```text
+-----------+--------------------------------+-----------------+------------------------------+
| branch_id | branch_name                    | branch_max_loan | average_of_branch_maximums   |
+-----------+--------------------------------+-----------------+------------------------------+
|         2 | Chicago Loop Commercial Branch |      1500000.00 |                    825000.00 |
|         1 | Manhattan Flagship Branch      |      1200000.00 |                    825000.00 |
+-----------+--------------------------------+-----------------+------------------------------+
```
