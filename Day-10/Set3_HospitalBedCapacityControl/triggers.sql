-- ============================================================================
-- Day 10: Triggers – MySQL 8.4 LTS
-- Set 3: Hospital Bed Capacity Control
-- File: triggers.sql
-- Description: Tasks 1 & 2:
--              Task 1: BEFORE INSERT trigger blocking admission when ward's
--                      occupied beds equal its capacity (meaningful error).
--              Task 2: AFTER INSERT, AFTER UPDATE, AFTER DELETE triggers
--                      recording every admission state change in admission_audit.
-- ============================================================================

DROP DATABASE IF EXISTS hospital_capacity_db;
CREATE DATABASE hospital_capacity_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hospital_capacity_db;

-- ----------------------------------------------------------------------------
-- Base Tables
-- ----------------------------------------------------------------------------
CREATE TABLE wards (
    ward_id INT AUTO_INCREMENT PRIMARY KEY,
    ward_name VARCHAR(50) NOT NULL UNIQUE,
    total_bed_capacity INT NOT NULL,
    occupied_beds INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_positive_capacity CHECK (total_bed_capacity > 0)
) ENGINE=InnoDB;

CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    emergency_contact VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE admissions (
    admission_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    ward_id INT NOT NULL,
    admission_status ENUM('ADMITTED', 'DISCHARGED', 'TRANSFERRED') NOT NULL DEFAULT 'ADMITTED',
    bed_number VARCHAR(10) NOT NULL,
    admitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    discharged_at DATETIME NULL,
    CONSTRAINT fk_adm_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_adm_ward FOREIGN KEY (ward_id) REFERENCES wards(ward_id)
) ENGINE=InnoDB;

CREATE TABLE admission_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    event_type ENUM('ADMISSION_CREATED', 'STATUS_CHANGED', 'ADMISSION_DELETED') NOT NULL,
    admission_id INT NOT NULL,
    patient_id INT NOT NULL,
    ward_id INT NOT NULL,
    previous_status VARCHAR(20) NULL,
    new_status VARCHAR(20) NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operator VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Baseline Data
-- ----------------------------------------------------------------------------
INSERT INTO wards (ward_id, ward_name, total_bed_capacity, occupied_beds) VALUES
(1, 'ICU Unit',           3, 2), -- 1 bed free
(2, 'Pediatric General',  5, 5), -- FULL
(3, 'Cardiology High Care', 4, 1);

INSERT INTO patients (patient_id, patient_name, emergency_contact) VALUES
(1, 'Ramesh Nair',   '+91-9988776611'),
(2, 'Sunita Sharma', '+91-9988776622'),
(3, 'John Fernandes', '+91-9988776633'),
(4, 'Deepa Das',     '+91-9988776644'),
(5, 'Kabir Mehta',   '+91-9988776655');

-- Baseline admissions for ICU (2 beds occupied)
INSERT INTO admissions (patient_id, ward_id, admission_status, bed_number) VALUES
(1, 1, 'ADMITTED', 'ICU-B1'),
(2, 1, 'ADMITTED', 'ICU-B2');

-- Baseline admissions for Pediatric (5 beds occupied - FULL)
INSERT INTO admissions (patient_id, ward_id, admission_status, bed_number) VALUES
(3, 2, 'ADMITTED', 'PED-B1');


-- ============================================================================
-- TASK 1: BEFORE INSERT Trigger - Ward Capacity Guard
-- ============================================================================
DELIMITER //

DROP TRIGGER IF EXISTS trg_admission_before_insert //
CREATE TRIGGER trg_admission_before_insert
BEFORE INSERT ON admissions
FOR EACH ROW
BEGIN
    DECLARE v_capacity INT;
    DECLARE v_occupied INT;

    -- Fetch current capacity & occupancy
    SELECT total_bed_capacity, occupied_beds 
    INTO v_capacity, v_occupied
    FROM wards
    WHERE ward_id = NEW.ward_id;

    -- Block admission if ward is full
    IF v_occupied >= v_capacity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hospital Admission Blocked: Target ward has reached 100% capacity. No beds available.';
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- TASK 2: AFTER INSERT, UPDATE, DELETE Triggers - Audit Trail & Occupancy Sync
-- ============================================================================
DELIMITER //

-- 1. AFTER INSERT
DROP TRIGGER IF EXISTS trg_admission_after_insert //
CREATE TRIGGER trg_admission_after_insert
AFTER INSERT ON admissions
FOR EACH ROW
BEGIN
    -- Log Audit
    INSERT INTO admission_audit (event_type, admission_id, patient_id, ward_id, previous_status, new_status, operator)
    VALUES ('ADMISSION_CREATED', NEW.admission_id, NEW.patient_id, NEW.ward_id, NULL, NEW.admission_status, CURRENT_USER());

    -- Increment occupied beds if admitted
    IF NEW.admission_status = 'ADMITTED' THEN
        UPDATE wards 
        SET occupied_beds = occupied_beds + 1 
        WHERE ward_id = NEW.ward_id;
    END IF;
END //

-- 2. AFTER UPDATE
DROP TRIGGER IF EXISTS trg_admission_after_update //
CREATE TRIGGER trg_admission_after_update
AFTER UPDATE ON admissions
FOR EACH ROW
BEGIN
    INSERT INTO admission_audit (event_type, admission_id, patient_id, ward_id, previous_status, new_status, operator)
    VALUES ('STATUS_CHANGED', NEW.admission_id, NEW.patient_id, NEW.ward_id, OLD.admission_status, NEW.admission_status, CURRENT_USER());

    -- Decrement occupied beds when discharged
    IF OLD.admission_status = 'ADMITTED' AND NEW.admission_status IN ('DISCHARGED', 'TRANSFERRED') THEN
        UPDATE wards 
        SET occupied_beds = GREATEST(occupied_beds - 1, 0)
        WHERE ward_id = OLD.ward_id;
    END IF;
END //

-- 3. AFTER DELETE
DROP TRIGGER IF EXISTS trg_admission_after_delete //
CREATE TRIGGER trg_admission_after_delete
AFTER DELETE ON admissions
FOR EACH ROW
BEGIN
    INSERT INTO admission_audit (event_type, admission_id, patient_id, ward_id, previous_status, new_status, operator)
    VALUES ('ADMISSION_DELETED', OLD.admission_id, OLD.patient_id, OLD.ward_id, OLD.admission_status, NULL, CURRENT_USER());

    IF OLD.admission_status = 'ADMITTED' THEN
        UPDATE wards 
        SET occupied_beds = GREATEST(occupied_beds - 1, 0)
        WHERE ward_id = OLD.ward_id;
    END IF;
END //

DELIMITER ;
