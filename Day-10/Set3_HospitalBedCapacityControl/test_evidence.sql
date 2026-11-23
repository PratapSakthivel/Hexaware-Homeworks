-- ============================================================================
-- Day 10: Triggers – MySQL 8.4 LTS
-- Set 3: Hospital Bed Capacity Control
-- File: test_evidence.sql
-- Description: Task 3 – Multi-row batch INSERT testing with capacity overflow;
--              demonstrates InnoDB transactional consistency & trigger invocation.
-- ============================================================================

USE hospital_capacity_db;

-- ----------------------------------------------------------------------------
-- 1. Test Valid Single Admission into ICU (Capacity 3, Occupied 2 -> Becomes 3)
-- ----------------------------------------------------------------------------
SELECT '=== WARDS BEFORE ADMISSION ===' AS step;
SELECT ward_id, ward_name, total_bed_capacity, occupied_beds FROM wards WHERE ward_id = 1;

INSERT INTO admissions (patient_id, ward_id, admission_status, bed_number)
VALUES (4, 1, 'ADMITTED', 'ICU-B3');

SELECT '=== WARDS AFTER VALID ADMISSION (OCCUPIED IS NOW 3) ===' AS step;
SELECT ward_id, ward_name, total_bed_capacity, occupied_beds FROM wards WHERE ward_id = 1;

SELECT '=== AUDIT TRAIL LOG ===' AS step;
SELECT * FROM admission_audit;


-- ----------------------------------------------------------------------------
-- 2. Test Admission Rejection on Full Ward (Pediatric Ward is at 5/5)
-- ----------------------------------------------------------------------------
-- Attempting to admit another patient into Ward 2 (Pediatric)
-- Expected: ERROR 1644 (45000): Hospital Admission Blocked: Target ward has reached 100% capacity. No beds available.
/*
INSERT INTO admissions (patient_id, ward_id, admission_status, bed_number)
VALUES (5, 2, 'ADMITTED', 'PED-B6');
*/


-- ----------------------------------------------------------------------------
-- 3. Test Multi-Row Batch INSERT Overflow
-- Attempt to admit 2 patients into ICU (which currently has 0 beds free).
-- InnoDB evaluates row-by-row; on the first failure, the entire multi-row statement rolls back!
-- ----------------------------------------------------------------------------
START TRANSACTION;

/*
INSERT INTO admissions (patient_id, ward_id, admission_status, bed_number) VALUES
(4, 3, 'ADMITTED', 'CARD-B2'), -- Valid
(5, 1, 'ADMITTED', 'ICU-OVERFLOW'); -- Fails!
*/

ROLLBACK;
