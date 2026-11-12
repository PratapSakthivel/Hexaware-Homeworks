-- ============================================================================
-- Day 5: Databases, Normalisation and Data Definition - MySQL 8.4 LTS
-- Set 3: Hospital Patient Records
-- File: schema.sql
-- ============================================================================

DROP DATABASE IF EXISTS hospital_records_db;
CREATE DATABASE hospital_records_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE hospital_records_db;

-- 1. Departments Table
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    building_floor VARCHAR(20) NOT NULL,
    head_of_department VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_department_name UNIQUE (department_name)
) ENGINE=InnoDB;

-- 2. Patients Table
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_code VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('M', 'F', 'OTHER') NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_patient_code UNIQUE (patient_code)
) ENGINE=InnoDB;

-- 3. Doctors Table
CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_code VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    department_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_doctor_code UNIQUE (doctor_code),
    CONSTRAINT fk_doctors_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4. Visits Table
CREATE TABLE visits (
    visit_id INT AUTO_INCREMENT PRIMARY KEY,
    visit_code VARCHAR(25) NOT NULL,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    visit_date DATETIME NOT NULL,
    diagnosis TEXT NOT NULL,
    prescription TEXT NOT NULL,
    visit_status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_visit_code UNIQUE (visit_code),
    CONSTRAINT chk_visit_status CHECK (visit_status IN ('OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    CONSTRAINT fk_visits_patient
        FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_visits_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 5. Billings Table
CREATE TABLE billings (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    bill_number VARCHAR(25) NOT NULL,
    visit_id INT NOT NULL,
    bill_amount DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    net_amount DECIMAL(10, 2) GENERATED ALWAYS AS (bill_amount - discount_amount) STORED,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    billed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_bill_number UNIQUE (bill_number),
    CONSTRAINT uq_billing_visit UNIQUE (visit_id),
    CONSTRAINT chk_bill_amount CHECK (bill_amount >= 0.00),
    CONSTRAINT chk_discount_amount CHECK (discount_amount >= 0.00 AND discount_amount <= bill_amount),
    CONSTRAINT chk_payment_status CHECK (payment_status IN ('OPEN', 'PARTIALLY_PAID', 'PAID', 'WAIVED')),
    CONSTRAINT fk_billings_visit
        FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;
