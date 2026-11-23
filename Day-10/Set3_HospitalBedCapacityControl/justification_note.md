# Set 3: Hospital Bed Capacity Control – Justification Note & JDBC Testing

## Overview
This document delivers the technical documentation for **Set 3 – Hospital Bed Capacity Control** under **MySQL 8.4 LTS**. It compares CHECK constraints, triggers, and stored procedures for capacity enforcement, and details how to test trigger failures from an application layer using Java JDBC.

---

## 1. Comparing Enforcement Mechanisms: Trigger vs CHECK Constraint vs Stored Procedure

```
+-------------------------------------------------------------------------------------------------------+
| Mechanism           | Cross-Table Capability | Error Customization | Performance | Portability & ACID |
+-------------------------------------------------------------------------------------------------------+
| CHECK Constraint    | Single-table only      | Generic DB code     | Highest     | ANSI SQL Standard  |
| BEFORE Trigger      | Multi-table queries    | Custom SIGNAL msg   | Medium      | Vendor Specific    |
| Stored Procedure    | Full workflow & locks  | Full procedural OUT | Controlled  | High               |
+-------------------------------------------------------------------------------------------------------+
```

### Detailed Evaluation:
1. **CHECK Constraint:** In MySQL 8.0+, CHECK constraints are enforced. However, ANSI SQL CHECK constraints cannot evaluate subqueries or query other tables (e.g. `CHECK (occupied_beds <= total_bed_capacity)` works on the `wards` table itself, but cannot query `admissions` dynamically from another table).
2. **BEFORE Trigger:** Ideal for intercepting direct raw `INSERT INTO admissions` statements executed by legacy applications, reporting tools, or direct DBA consoles.
3. **Stored Procedure (`sp_admit_patient`):** Recommended for high-concurrency production systems because it can explicitly acquire pessimistic locks (`SELECT ... FOR UPDATE` on `wards`), avoiding race conditions when two nurses click "Admit" concurrently.

---

## 2. JDBC Integration & Unit Testing Pattern

When testing trigger rejections from Java (JDK 21 / JDK 25 LTS) using JDBC:
```java
try (Connection conn = dataSource.getConnection();
     PreparedStatement pstmt = conn.prepareStatement(
         "INSERT INTO admissions (patient_id, ward_id, admission_status, bed_number) VALUES (?, ?, ?, ?)")) {
    
    pstmt.setInt(1, 5);
    pstmt.setInt(2, 2); // Ward 2 is FULL
    pstmt.setString(3, "ADMITTED");
    pstmt.setString(4, "BED-99");
    
    pstmt.executeUpdate();
    fail("Expected SQLException due to capacity trigger was not thrown!");

} catch (SQLException ex) {
    // MySQL SIGNAL 45000 translates to SQLState 45000 and Vendor Error 1644
    assertEquals("45000", ex.getSQLState());
    assertEquals(1644, ex.getErrorCode());
    assertTrue(ex.getMessage().contains("Hospital Admission Blocked: Target ward has reached 100% capacity"));
}
```
This guarantees that application developers handle user-friendly capacity error alerts without crashing backend microservices.
