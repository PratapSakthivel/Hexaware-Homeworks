# Set 1: Retail Order Fulfilment – Cursor vs Set-Based Comparison & Functions Note

## Overview
This document delivers the technical analysis for **Set 1 – Retail Order Fulfilment** under **MySQL 8.4 LTS**. It compares Stored Functions vs Stored Procedures, examines `WITH CHECK OPTION` on updatable views, and provides an empirical evaluation of **Cursor-based row-by-row iteration vs Set-based relational statements**.

---

## 1. Stored Functions vs Stored Procedures Comparison

| Feature / Dimension | Stored Function (`CREATE FUNCTION`) | Stored Procedure (`CREATE PROCEDURE`) |
|:---|:---|:---|
| **Return Value** | Must return exactly one deterministic scalar value via `RETURNS <type>`. | Returns zero, one, or multiple values via `OUT` or `INOUT` parameters, or result sets. |
| **SQL Expression Usage** | Callable directly inside `SELECT`, `WHERE`, `ORDER BY`, `HAVING` expressions. | Cannot be called inside a `SELECT`; must be invoked via `CALL procedure_name(...)`. |
| **Transaction Control** | Cannot execute transaction control statements (`START TRANSACTION`, `COMMIT`, `ROLLBACK`). | Fully supports explicit transaction control blocks and `SAVEPOINT` management. |
| **DML Side Effects** | Strongly discouraged; cannot modify tables if called within queries reading from that table. | Designed for heavy batch DML operations, inserts, updates, and complex multi-table workflows. |
| **Primary Use Case** | Business calculations (e.g., GST/VAT computation, discounts, formatted strings). | Business workflows, multi-step transaction pipelines, batch validations, data synchronization. |

---

## 2. Cursor vs Set-Based Processing Analysis

### Why Set-Based Outperforms Cursors
Relational database management engines (RDBMS) like MySQL InnoDB are fundamentally optimized for **set operations**, leveraging relational algebra, vector processing, and bulk page I/O.

```
+-----------------------------------------------------------------------------------------------+
| Feature              | Cursor Processing (Iterative RBAR)  | Set-Based Processing (Declarative) |
+-----------------------------------------------------------------------------------------------+
| Execution Style      | Row-By-Agonizing-Row (RBAR)         | Single-pass relational set scan  |
| Context Switches     | High (engine to procedural handler) | Zero (internal optimizer plan)   |
| Lock Overhead        | Extended lock duration per row      | Short, atomic statement lock     |
| Memory Footprint     | Result set cached in temporary table| Streamed or hash/index scanned   |
| 100k Rows Scalability| Several minutes (High CPU)          | Milliseconds (Sub-second)        |
+-----------------------------------------------------------------------------------------------+
```

### Recommendation
Always implement declarative `INSERT ... SELECT` or `UPDATE ... JOIN` statements. Reserve cursors strictly for workflows requiring external API calls per row or distinct non-deterministic procedural branching.
