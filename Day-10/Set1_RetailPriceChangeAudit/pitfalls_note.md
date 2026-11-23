# Set 1: Retail Price Change Audit – Trigger Mechanics & Pitfalls Note

## Overview
This technical note details the trigger architecture, row-level execution semantics, and architectural pitfalls for **Set 1 – Retail Price Change Audit** under **MySQL 8.4 LTS**.

---

## 1. Row-Level Trigger Behavior in MySQL
Unlike some database systems (such as PostgreSQL or Oracle) that support both Statement-Level (`FOR EACH STATEMENT`) and Row-Level (`FOR EACH ROW`) triggers:
- **MySQL triggers are strictly row-level.**
- When a single `UPDATE product_price SET selling_price = selling_price * 1.05;` modifies 4 rows, MySQL evaluates the `BEFORE UPDATE` trigger 4 consecutive times and executes the `AFTER UPDATE` trigger 4 consecutive times.
- If the 3rd row triggers a `SIGNAL SQLSTATE '45000'`, the entire statement and transaction abort, reverting changes for all 4 rows.

---

## 2. Trigger Risks & Architectural Pitfalls

### Risk 1: Hidden Business Logic & Obscured Debugging
Triggers execute implicitly behind the scenes. Developers modifying application code or running migration scripts often have no visual indicator that a simple `UPDATE` cascades into side-effect writes. 
- **Impact:** Performance degradation during batch data loads (e.g. ETL pipelines), unexpected lock escalation, and difficult root-cause analysis when queries fail mysteriously.

### Risk 2: Cascading Trigger Storms & Mutation Recursion
If an `AFTER UPDATE` trigger on Table A updates Table B, and Table B has a trigger that updates Table A, an infinite cascade loop occurs until MySQL exceeds its maximum execution depth (`max_sp_recursion_depth`), crashing the transaction.

---

## 3. When Application Code is Superior to Triggers
1. **Third-Party Integrations:** Sending SMS notifications, dispatching webhooks, or calling Stripe/Razorpay payment APIs should never run in a database trigger because network latency blocks database threads and extends transaction lock durations.
2. **Complex Domain Validations:** Business rules requiring cross-service validations, caching layers (Redis), or microservice orchestration belong in application service layers (Spring Boot / Java domain models) where automated unit tests can mock external dependencies cleanly.
