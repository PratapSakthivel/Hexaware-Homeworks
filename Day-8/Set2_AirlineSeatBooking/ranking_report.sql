-- ============================================================================
-- Day 8: CTEs, Window Functions and Transactions – MySQL 8.4 LTS
-- Set 2: Airline Seat Booking
-- File: ranking_report.sql
-- Description: Tasks 3, 4 & 5 – Passenger fare ranking using RANK() and
--              DENSE_RANK(), revenue running totals using CTE and SUM() OVER,
--              and correlated subquery filtering fares above flight average.
-- ============================================================================

USE airline_booking_db;

-- ----------------------------------------------------------------------------
-- Populate Comprehensive Flight Booking Data
-- ----------------------------------------------------------------------------
-- Book seats on Flight 1 (AI-202)
INSERT INTO bookings (booking_reference, passenger_id, flight_id, seat_id, fare_paid, booking_status) VALUES
('PNR-2026-0002', 2, 1, 2, 18500.00, 'CONFIRMED'),  -- Tied Top Business Fare (18,500)
('PNR-2026-0003', 3, 1, 3,  8200.00, 'CONFIRMED'),  -- Premium Economy (8,200)
('PNR-2026-0004', 4, 1, 4,  8200.00, 'CONFIRMED'),  -- Tied Premium Economy (8,200)
('PNR-2026-0005', 5, 1, 5,  4500.00, 'CONFIRMED');  -- Economy (4,500)

UPDATE flight_seats SET status = 'BOOKED' WHERE seat_id IN (2, 3, 4, 5);

-- Additional Passengers & Bookings for Flight 2 (6E-451)
INSERT INTO passengers (passenger_id, first_name, last_name, email) VALUES
(6, 'Meera', 'Nair',       'meera.n@example.com'),
(7, 'Gaurav', 'Kapoor',    'gaurav.k@example.com'),
(8, 'Swati', 'Deshmukh',   'swati.d@example.com'),
(9, 'Nikhil', 'Joshi',     'nikhil.j@example.com');

INSERT INTO bookings (booking_reference, passenger_id, flight_id, seat_id, fare_paid, booking_status) VALUES
('PNR-2026-0006', 6, 2, 8,  5500.00, 'CONFIRMED'),  -- Premium Economy
('PNR-2026-0007', 7, 2, 9,  5500.00, 'CONFIRMED'),  -- Tied Premium Economy
('PNR-2026-0008', 8, 2, 10, 3200.00, 'CONFIRMED'),  -- Economy
('PNR-2026-0009', 9, 2, 12, 2900.00, 'CONFIRMED');  -- Economy

UPDATE flight_seats SET status = 'BOOKED' WHERE seat_id IN (8, 9, 10, 12);


-- ============================================================================
-- TASK 3: Ranked Report of Passengers by Fare Per Flight (RANK vs DENSE_RANK)
-- ============================================================================
SELECT 
    f.flight_number,
    f.origin,
    f.destination,
    CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
    fs.seat_number,
    fs.seat_class,
    b.fare_paid,
    -- RANK skips positions after duplicate/tied values
    RANK() OVER (
        PARTITION BY b.flight_id 
        ORDER BY b.fare_paid DESC
    ) AS fare_rank,
    -- DENSE_RANK maintains contiguous integer ranks without gaps
    DENSE_RANK() OVER (
        PARTITION BY b.flight_id 
        ORDER BY b.fare_paid DESC
    ) AS fare_dense_rank
FROM bookings b
JOIN flights f ON b.flight_id = f.flight_id
JOIN passengers p ON b.passenger_id = p.passenger_id
JOIN flight_seats fs ON b.seat_id = fs.seat_id
WHERE b.booking_status = 'CONFIRMED'
ORDER BY f.flight_id, fare_dense_rank ASC, p.last_name ASC;


-- ============================================================================
-- TASK 4: CTE Report with Running Total of Revenue Per Flight
-- Using SUM() OVER (PARTITION BY ... ORDER BY ...)
-- ============================================================================
WITH FlightPassengerRevenueCTE AS (
    SELECT 
        b.booking_id,
        f.flight_number,
        CONCAT(f.origin, ' -> ', f.destination) AS flight_route,
        b.booking_reference,
        CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
        fs.seat_number,
        fs.seat_class,
        b.fare_paid,
        b.booking_time,
        DENSE_RANK() OVER (
            PARTITION BY b.flight_id 
            ORDER BY b.fare_paid DESC
        ) AS fare_rank_dense,
        -- Running total accumulated sequentially as bookings occur or by fare order
        SUM(b.fare_paid) OVER (
            PARTITION BY b.flight_id 
            ORDER BY b.booking_id ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_flight_revenue,
        -- Total flight revenue window aggregate
        SUM(b.fare_paid) OVER (
            PARTITION BY b.flight_id
        ) AS total_flight_revenue
    FROM bookings b
    JOIN flights f ON b.flight_id = f.flight_id
    JOIN passengers p ON b.passenger_id = p.passenger_id
    JOIN flight_seats fs ON b.seat_id = fs.seat_id
    WHERE b.booking_status = 'CONFIRMED'
)
SELECT 
    flight_number,
    flight_route,
    booking_reference,
    passenger_name,
    seat_number,
    seat_class,
    fare_paid,
    cumulative_flight_revenue,
    total_flight_revenue,
    ROUND((cumulative_flight_revenue * 100.0) / total_flight_revenue, 1) AS revenue_progress_pct
FROM FlightPassengerRevenueCTE
ORDER BY flight_number, booking_id ASC;


-- ============================================================================
-- TASK 5: Correlated Subquery – Passengers Whose Fare Exceeds Flight Average
-- ============================================================================
SELECT 
    b.booking_reference,
    f.flight_number,
    CONCAT(f.origin, ' -> ', f.destination) AS route,
    CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
    fs.seat_number,
    fs.seat_class,
    b.fare_paid,
    -- Correlated scalar subquery showing the benchmark average fare for that flight
    (
        SELECT ROUND(AVG(b_inner.fare_paid), 2)
        FROM bookings b_inner
        WHERE b_inner.flight_id = b.flight_id
          AND b_inner.booking_status = 'CONFIRMED'
    ) AS flight_average_fare,
    ROUND(b.fare_paid - (
        SELECT AVG(b_inner.fare_paid)
        FROM bookings b_inner
        WHERE b_inner.flight_id = b.flight_id
          AND b_inner.booking_status = 'CONFIRMED'
    ), 2) AS premium_above_average
FROM bookings b
JOIN flights f ON b.flight_id = f.flight_id
JOIN passengers p ON b.passenger_id = p.passenger_id
JOIN flight_seats fs ON b.seat_id = fs.seat_id
WHERE b.booking_status = 'CONFIRMED'
  AND b.fare_paid > (
      -- Correlated filtering predicate
      SELECT AVG(b_sub.fare_paid)
      FROM bookings b_sub
      WHERE b_sub.flight_id = b.flight_id
        AND b_sub.booking_status = 'CONFIRMED'
  )
ORDER BY f.flight_number, b.fare_paid DESC;
