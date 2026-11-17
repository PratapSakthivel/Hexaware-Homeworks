# Set 2: Airline Seat Booking – Locking Behavior & Window Functions Technical Note

## Overview
This technical note documents the transaction locking mechanics, pessimistic concurrency control, and analytical window functions implemented for **Set 2 – Airline Seat Booking** in **MySQL 8.4 LTS**.

---

## 1. Concurrency Simulation & Locking Behavior Analysis

### The Scenario: Two Simultaneous Bookings for Seat `1B` on Flight `AI-202`
When high demand spikes occur (e.g., flash sales, holiday bookings), multiple users attempt to reserve the same physical seat at the same millisecond. Without rigorous isolation, race conditions cause **double-booking**, resulting in customer friction and airline regulatory penalties.

### Step-by-Step Locking Sequence (InnoDB Engine)

```
        Session 1 (Passenger: Kavita)                Session 2 (Passenger: Arun)
                     |                                            |
T1: START TRANSACTION;                                            |
                     |                                            |
T2: SELECT ... FOR UPDATE;                                        |
    (Acquires exclusive X-lock on seat 1B)                        |
                     |                                            |
T3:                  |                                   START TRANSACTION;
                     |                                            |
T4:                  |                                   SELECT ... FOR UPDATE;
                     |                              [BLOCKED by InnoDB lock manager]
                     |                              [Session 2 enters lock wait state]
                     |                                            |
T5: INSERT INTO bookings ...                                      |
    UPDATE flight_seats SET status='BOOKED';                      |
                     |                                            |
T6: COMMIT;                                                       |
    [X-lock on seat 1B is RELEASED]                               |
                     |                                            |
T7:                  |                                   [WAKES UP IMMEDIATELY]
                     |                                   Reads status = 'BOOKED'
                     |                                   Detects seat unavailable
                     |                                   ROLLBACK;
```

### Key Technical Observations
1. **Pessimistic Row-Level Locking (`SELECT ... FOR UPDATE`):**
   - InnoDB places an exclusive (`X`) record lock on the index record corresponding to `(flight_id=1, seat_number='1B')`.
   - While Session 1 holds the lock, no other transaction can read with `FOR UPDATE` or `LOCK IN SHARE MODE`, nor can any transaction `UPDATE` or `DELETE` that row.
2. **Lock Wait Timeout (`innodb_lock_wait_timeout`):**
   - Session 2 waits up to `50 seconds` (default `innodb_lock_wait_timeout`). If Session 1 does not commit within that duration, Session 2 throws:
     `ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction`.
3. **Deadlock Immunity via Predicate Consistency:**
   - Both transactions query the single row using the unique index `(flight_id, seat_number)`. Because they request the exact same row lock, one cleanly queues behind the other without mutual blocking cycles (deadlocks).

---

## 2. Window Functions: `RANK()` vs `DENSE_RANK()` with Tied Fares

### Expected Output (`ranking_report.sql` Task 3)

```
+---------------+--------+-------------+------------------+-------------+-----------------+-----------+-----------+-----------------+
| flight_number | origin | destination | passenger_name   | seat_number | seat_class      | fare_paid | fare_rank | fare_dense_rank |
+---------------+--------+-------------+------------------+-------------+-----------------+-----------+-----------+-----------------+
| AI-202        | BOM    | DEL         | Kavita Krishnan  | 1B          | BUSINESS        |  18500.00 |         1 |               1 |
| AI-202        | BOM    | DEL         | Rohit Sharma     | 1A          | BUSINESS        |  18500.00 |         1 |               1 |
| AI-202        | BOM    | DEL         | Arun Sundaram    | 12A         | PREMIUM_ECONOMY |   8200.00 |         3 |               2 |
| AI-202        | BOM    | DEL         | Deepak Verma     | 12B         | PREMIUM_ECONOMY |   8200.00 |         3 |               2 |
| AI-202        | BOM    | DEL         | Sunita Menon     | 21A         | ECONOMY         |   4500.00 |         5 |               3 |
| 6E-451        | BLR    | MAA         | Gaurav Kapoor    | 1B          | PREMIUM_ECONOMY |   5500.00 |         1 |               1 |
| 6E-451        | BLR    | MAA         | Meera Nair       | 1A          | PREMIUM_ECONOMY |   5500.00 |         1 |               1 |
| 6E-451        | BLR    | MAA         | Swati Deshmukh   | 10A         | ECONOMY         |   3200.00 |         3 |               2 |
| 6E-451        | BLR    | MAA         | Nikhil Joshi     | 10C         | ECONOMY         |   2900.00 |         4 |               3 |
+---------------+--------+-------------+------------------+-------------+-----------------+-----------+-----------+-----------------+
```

### Explanation of the Difference Under Tied Fares
- **Tied Business Fares (₹18,500.00):** Both Kavita and Rohit are assigned Rank `1`.
- **Next Tier (Premium Economy - ₹8,200.00):**
  - **`RANK()`** recognizes that two passengers occupy rank 1. It **skips** position 2 and assigns both Arun and Deepak **Rank 3** (`1, 1, 3, 3, 5`).
  - **`DENSE_RANK()`** ignores gaps and assigns the next immediate sequential integer, giving Arun and Deepak **Rank 2** (`1, 1, 2, 2, 3`).
- **Commercial Impact:**
  - `RANK()` is required for Olympic-style competition awards or prize eligibility where ties consume positions.
  - `DENSE_RANK()` is preferred for fare tier classification, revenue categorization, and frequent flyer bracket assignment.

---

## 3. CTE with Running Total Revenue (`SUM() OVER`)

### Expected Output (Task 4)
```
+---------------+----------------+-------------------+------------------+-------------+-----------------+-----------+---------------------------+----------------------+----------------------+
| flight_number | flight_route   | booking_reference | passenger_name   | seat_number | seat_class      | fare_paid | cumulative_flight_revenue | total_flight_revenue | revenue_progress_pct |
+---------------+----------------+-------------------+------------------+-------------+-----------------+-----------+---------------------------+----------------------+----------------------+
| AI-202        | BOM -> DEL     | PNR-2026-0001     | Rohit Sharma     | 1A          | BUSINESS        |  18500.00 |                  18500.00 |             57900.00 |                 32.0 |
| AI-202        | BOM -> DEL     | PNR-2026-0002     | Kavita Krishnan  | 1B          | BUSINESS        |  18500.00 |                  37000.00 |             57900.00 |                 63.9 |
| AI-202        | BOM -> DEL     | PNR-2026-0003     | Arun Sundaram    | 12A         | PREMIUM_ECONOMY |   8200.00 |                  45200.00 |             57900.00 |                 78.1 |
| AI-202        | BOM -> DEL     | PNR-2026-0004     | Deepak Verma     | 12B         | PREMIUM_ECONOMY |   8200.00 |                  53400.00 |             57900.00 |                 92.2 |
| AI-202        | BOM -> DEL     | PNR-2026-0005     | Sunita Menon     | 21A         | ECONOMY         |   4500.00 |                  57900.00 |             57900.00 |                100.0 |
+---------------+----------------+-------------------+------------------+-------------+-----------------+-----------+---------------------------+----------------------+----------------------+
```
The window function `SUM(fare_paid) OVER (PARTITION BY flight_id ORDER BY booking_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)` enables real-time booking revenue velocity tracking without expensive self-joins.

---

## 4. Correlated Subquery: Fares Above Flight Average

### Expected Output (Task 5)
```
+-------------------+---------------+------------+------------------+-------------+-----------------+-----------+---------------------+-----------------------+
| booking_reference | flight_number | route      | passenger_name   | seat_number | seat_class      | fare_paid | flight_average_fare | premium_above_average |
+-------------------+---------------+------------+------------------+-------------+-----------------+-----------+---------------------+-----------------------+
| PNR-2026-0001     | AI-202        | BOM -> DEL | Rohit Sharma     | 1A          | BUSINESS        |  18500.00 |            11580.00 |               6920.00 |
| PNR-2026-0002     | AI-202        | BOM -> DEL | Kavita Krishnan  | 1B          | BUSINESS        |  18500.00 |            11580.00 |               6920.00 |
| PNR-2026-0006     | 6E-451        | BLR -> MAA | Meera Nair       | 1A          | PREMIUM_ECONOMY |   5500.00 |             4275.00 |               1225.00 |
| PNR-2026-0007     | 6E-451        | BLR -> MAA | Gaurav Kapoor    | 1B          | PREMIUM_ECONOMY |   5500.00 |             4275.00 |               1225.00 |
+-------------------+---------------+------------+------------------+-------------+-----------------+-----------+---------------------+-----------------------+
```
- Flight `AI-202` average fare = ₹11,580.00; Business passengers paid a +₹6,920.00 premium.
- Flight `6E-451` average fare = ₹4,275.00; Premium Economy passengers paid a +₹1,225.00 premium.
