-- ============================================================================
-- Day 8: CTEs, Window Functions and Transactions – MySQL 8.4 LTS
-- Set 2: Airline Seat Booking
-- File: booking_transaction.sql
-- Description: Task 1 & 2 – Atomic airline seat reservation transaction with
--              exclusive row locking (SELECT ... FOR UPDATE) and concurrent
--              simulation script.
-- ============================================================================

DROP DATABASE IF EXISTS airline_booking_db;
CREATE DATABASE airline_booking_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE airline_booking_db;

-- ----------------------------------------------------------------------------
-- Table DDL
-- ----------------------------------------------------------------------------

-- Flights Table
CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL UNIQUE,
    origin VARCHAR(10) NOT NULL,
    destination VARCHAR(10) NOT NULL,
    departure_time DATETIME NOT NULL,
    total_seats INT NOT NULL DEFAULT 180
) ENGINE=InnoDB;

-- Flight Seats Table
CREATE TABLE flight_seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_class ENUM('ECONOMY', 'PREMIUM_ECONOMY', 'BUSINESS') NOT NULL DEFAULT 'ECONOMY',
    base_price DECIMAL(10, 2) NOT NULL,
    status ENUM('AVAILABLE', 'HELD', 'BOOKED') NOT NULL DEFAULT 'AVAILABLE',
    version INT NOT NULL DEFAULT 1,
    CONSTRAINT uq_flight_seat UNIQUE (flight_id, seat_number),
    CONSTRAINT fk_seat_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
) ENGINE=InnoDB;

-- Passengers Table
CREATE TABLE passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    frequent_flyer_number VARCHAR(30) NULL
) ENGINE=InnoDB;

-- Bookings Table
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_reference VARCHAR(20) NOT NULL UNIQUE,
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
    seat_id INT NOT NULL UNIQUE, -- Ensures 1-to-1 seat booking integrity
    fare_paid DECIMAL(10, 2) NOT NULL,
    booking_status ENUM('CONFIRMED', 'CANCELLED', 'REFUNDED') NOT NULL DEFAULT 'CONFIRMED',
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_booking_passenger FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    CONSTRAINT fk_booking_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    CONSTRAINT fk_booking_seat FOREIGN KEY (seat_id) REFERENCES flight_seats(seat_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Baseline Seed Data
-- ----------------------------------------------------------------------------
INSERT INTO flights (flight_id, flight_number, origin, destination, departure_time) VALUES
(1, 'AI-202', 'BOM', 'DEL', '2026-11-20 06:00:00'),
(2, '6E-451', 'BLR', 'MAA', '2026-11-20 08:30:00'),
(3, 'UK-819', 'DEL', 'HYD', '2026-11-20 14:15:00');

-- Seats for Flight 1 (AI-202)
INSERT INTO flight_seats (seat_id, flight_id, seat_number, seat_class, base_price, status) VALUES
(1, 1, '1A', 'BUSINESS',         18500.00, 'AVAILABLE'),
(2, 1, '1B', 'BUSINESS',         18500.00, 'AVAILABLE'),
(3, 1, '12A', 'PREMIUM_ECONOMY',  8200.00, 'AVAILABLE'),
(4, 1, '12B', 'PREMIUM_ECONOMY',  8200.00, 'AVAILABLE'),
(5, 1, '21A', 'ECONOMY',          4500.00, 'AVAILABLE'),
(6, 1, '21B', 'ECONOMY',          4500.00, 'AVAILABLE'),
(7, 1, '21C', 'ECONOMY',          4500.00, 'AVAILABLE');

-- Seats for Flight 2 (6E-451)
INSERT INTO flight_seats (seat_id, flight_id, seat_number, seat_class, base_price, status) VALUES
(8,  2, '1A',  'PREMIUM_ECONOMY', 5500.00, 'AVAILABLE'),
(9,  2, '1B',  'PREMIUM_ECONOMY', 5500.00, 'AVAILABLE'),
(10, 2, '10A', 'ECONOMY',          3200.00, 'AVAILABLE'),
(11, 2, '10B', 'ECONOMY',          3200.00, 'AVAILABLE'),
(12, 2, '10C', 'ECONOMY',          2900.00, 'AVAILABLE');

-- Baseline Passengers
INSERT INTO passengers (passenger_id, first_name, last_name, email) VALUES
(1, 'Rohit', 'Sharma',    'rohit.sharma@example.com'),
(2, 'Kavita', 'Krishnan', 'kavita.k@example.com'),
(3, 'Arun', 'Sundaram',   'arun.s@example.com'),
(4, 'Deepak', 'Verma',    'deepak.v@example.com'),
(5, 'Sunita', 'Menon',    'sunita.m@example.com');


-- ============================================================================
-- TASK 1: Atomic Booking Transaction Procedure with SELECT ... FOR UPDATE
-- ============================================================================
DELIMITER //

DROP PROCEDURE IF EXISTS sp_book_seat //
CREATE PROCEDURE sp_book_seat(
    IN p_flight_id INT,
    IN p_seat_number VARCHAR(10),
    IN p_passenger_id INT,
    IN p_booking_ref VARCHAR(20),
    OUT p_status_message VARCHAR(150)
)
proc_label: BEGIN
    DECLARE v_seat_id INT;
    DECLARE v_current_status VARCHAR(20);
    DECLARE v_fare DECIMAL(10, 2);

    -- Rollback on any SQL exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_message = 'ERROR: Database exception occurred during seat booking. Transaction rolled back.';
    END;

    -- Begin atomic transaction
    START TRANSACTION;

    -- Step 1: Exclusive pessimistic lock on target seat
    SELECT seat_id, status, base_price 
    INTO v_seat_id, v_current_status, v_fare
    FROM flight_seats
    WHERE flight_id = p_flight_id AND seat_number = p_seat_number
    FOR UPDATE;

    -- Validate seat existence
    IF v_seat_id IS NULL THEN
        ROLLBACK;
        SET p_status_message = CONCAT('REJECTED: Seat ', p_seat_number, ' does not exist on flight ', p_flight_id);
        LEAVE proc_label;
    END IF;

    -- Validate availability
    IF v_current_status <> 'AVAILABLE' THEN
        ROLLBACK;
        SET p_status_message = CONCAT('REJECTED: Seat ', p_seat_number, ' is already ', v_current_status, '. Booking aborted.');
        LEAVE proc_label;
    END IF;

    -- Step 2: Insert booking record
    INSERT INTO bookings (booking_reference, passenger_id, flight_id, seat_id, fare_paid, booking_status)
    VALUES (p_booking_ref, p_passenger_id, p_flight_id, v_seat_id, v_fare, 'CONFIRMED');

    -- Step 3: Update seat status to BOOKED
    UPDATE flight_seats
    SET status = 'BOOKED'
    WHERE seat_id = v_seat_id;

    -- Step 4: Commit transaction
    COMMIT;
    SET p_status_message = CONCAT('CONFIRMED: Seat ', p_seat_number, ' successfully booked for passenger ', p_passenger_id, ' (Ref: ', p_booking_ref, ')');
END //

DELIMITER ;

-- Test Single Seat Booking
SET @msg = '';
CALL sp_book_seat(1, '1A', 1, 'PNR-2026-0001', @msg);
SELECT @msg AS booking_result;

-- View Seat status after booking
SELECT seat_id, flight_id, seat_number, seat_class, base_price, status 
FROM flight_seats WHERE seat_id = 1;


-- ============================================================================
-- TASK 2: Script to Simulate Two Simultaneous Bookings for the Same Seat
-- ============================================================================
/*
-- ----------------------------------------------------------------------------
-- Two Concurrent Terminal Simulation Guide (Seat 1B on Flight 1)
-- ----------------------------------------------------------------------------
-- Session 1 (User: Kavita Krishnan, Passenger ID: 2):
USE airline_booking_db;
START TRANSACTION;
SELECT seat_id, seat_number, status, base_price 
FROM flight_seats 
WHERE flight_id = 1 AND seat_number = '1B' 
FOR UPDATE;
-- [Session 1 now holds exclusive X-lock on seat 1B!]
-- (Pause here for 5 seconds to allow Session 2 to attempt booking)

-- Session 2 (User: Arun Sundaram, Passenger ID: 3):
USE airline_booking_db;
START TRANSACTION;
SELECT seat_id, seat_number, status, base_price 
FROM flight_seats 
WHERE flight_id = 1 AND seat_number = '1B' 
FOR UPDATE;
-- [OBSERVE: Session 2 immediately pauses/blocks waiting for lock release!]

-- Back to Session 1:
INSERT INTO bookings (booking_reference, passenger_id, flight_id, seat_id, fare_paid, booking_status)
VALUES ('PNR-2026-0002', 2, 1, 2, 18500.00, 'CONFIRMED');
UPDATE flight_seats SET status = 'BOOKED' WHERE seat_id = 2;
COMMIT;
-- [Session 1 commits! Exclusive lock is released!]

-- In Session 2 (Wakes up immediately upon Session 1's commit):
-- Session 2 now reads status = 'BOOKED'.
-- Session 2 detects status != 'AVAILABLE', terminates with:
ROLLBACK;
-- Result: Double-booking is strictly prevented by InnoDB row-level locking!
*/
