-- ============================================================================
-- Day 5: Databases, Normalisation and Data Definition - MySQL 8.4 LTS
-- Set 3: Hospital Patient Records
-- File: seed_data.sql
-- Description: Inserts records, queries patients visited in a given month,
--              doctors by department, and demonstrates database/table management.
-- ============================================================================

USE hospital_records_db;

-- ----------------------------------------------------------------------------
-- 1. SEED DATA INSERTION (Minimum 10 rows per table)
-- ----------------------------------------------------------------------------

-- Insert 10 Departments
INSERT INTO departments (department_id, department_name, building_floor, head_of_department) VALUES
(1, 'Cardiology', 'Wing A - 3rd Floor', 'Dr. Harold Finch'),
(2, 'Neurology', 'Wing B - 4th Floor', 'Dr. Gregory House'),
(3, 'Orthopedics', 'Wing A - 1st Floor', 'Dr. Lisa Cuddy'),
(4, 'Pediatrics', 'Wing C - 2nd Floor', 'Dr. Allison Cameron'),
(5, 'Oncology', 'Wing D - 5th Floor', 'Dr. James Wilson'),
(6, 'Dermatology', 'Wing B - 2nd Floor', 'Dr. Robert Chase'),
(7, 'Emergency Medicine', 'Ground Floor - Main', 'Dr. Eric Foreman'),
(8, 'Gastroenterology', 'Wing A - 4th Floor', 'Dr. Chris Taub'),
(9, 'Pulmonology', 'Wing C - 3rd Floor', 'Dr. Lawrence Kutner'),
(10, 'General Surgery', 'Wing D - 1st Floor', 'Dr. Remy Hadley');

-- Insert 10 Patients
INSERT INTO patients (patient_id, patient_code, first_name, last_name, date_of_birth, gender, phone, address) VALUES
(1, 'PAT-1001', 'Alice', 'Morgan', '1985-04-12', 'F', '+1-555-4001', '12 Maple Ave, Boston MA'),
(2, 'PAT-1002', 'Brandon', 'Stark', '1992-11-05', 'M', '+1-555-4002', '45 Winterfell Rd, Chicago IL'),
(3, 'PAT-1003', 'Clara', 'Oswald', '1990-07-23', 'F', '+1-555-4003', '77 Tardis Way, London UK'),
(4, 'PAT-1004', 'Daniel', 'Craig', '1968-03-02', 'M', '+1-555-4004', '007 MI6 Blvd, New York NY'),
(5, 'PAT-1005', 'Elena', 'Gilbert', '1994-06-22', 'F', '+1-555-4005', '21 Mystic Falls Rd, Atlanta GA'),
(6, 'PAT-1006', 'Felix', 'Kjellberg', '1989-10-24', 'M', '+1-555-4006', '89 Bro St, San Francisco CA'),
(7, 'PAT-1007', 'Grace', 'Hopper', '1975-12-09', 'F', '+1-555-4007', '1944 Compiler Ave, Arlington VA'),
(8, 'PAT-1008', 'Henry', 'Cavill', '1983-05-05', 'M', '+1-555-4008', '55 Metropolis Way, Dallas TX'),
(9, 'PAT-1009', 'Iris', 'West', '1993-08-14', 'F', '+1-555-4009', '35 Central City Ln, Seattle WA'),
(10, 'PAT-1010', 'Jack', 'Shephard', '1979-01-19', 'M', '+1-555-4010', '815 Oceanic Island, Honolulu HI');

-- Insert 10 Doctors
INSERT INTO doctors (doctor_id, doctor_code, first_name, last_name, specialization, phone, department_id) VALUES
(1, 'DOC-201', 'Harold', 'Finch', 'Interventional Cardiology', '+1-555-5001', 1),
(2, 'DOC-202', 'Gregory', 'House', 'Diagnostic Neurology', '+1-555-5002', 2),
(3, 'DOC-203', 'Lisa', 'Cuddy', 'Endocrinology & Admin', '+1-555-5003', 3),
(4, 'DOC-204', 'Allison', 'Cameron', 'Pediatric Immunology', '+1-555-5004', 4),
(5, 'DOC-205', 'James', 'Wilson', 'Clinical Oncology', '+1-555-5005', 5),
(6, 'DOC-206', 'Robert', 'Chase', 'Surgical Dermatology', '+1-555-5006', 6),
(7, 'DOC-207', 'Eric', 'Foreman', 'Emergency Trauma', '+1-555-5007', 7),
(8, 'DOC-208', 'Chris', 'Taub', 'Digestive Health', '+1-555-5008', 8),
(9, 'DOC-209', 'Lawrence', 'Kutner', 'Pulmonary Critical Care', '+1-555-5009', 9),
(10, 'DOC-210', 'Remy', 'Hadley', 'Internal & General Surgery', '+1-555-5010', 10);

-- Insert 12 Visits (Minimum 10 rows)
INSERT INTO visits (visit_id, visit_code, patient_id, doctor_id, visit_date, diagnosis, prescription, visit_status) VALUES
(1, 'VST-2026-001', 1, 1, '2026-10-04 09:30:00', 'Mild Arrhythmia & Hypertension', 'Metoprolol 25mg daily, Low sodium diet', 'COMPLETED'),
(2, 'VST-2026-002', 2, 2, '2026-10-08 11:15:00', 'Persistent Migraine Aura', 'Sumatriptan 50mg PRN, Brain MRI scheduled', 'COMPLETED'),
(3, 'VST-2026-003', 3, 3, '2026-10-12 14:00:00', 'Acute Knee Ligament Sprain', 'Ibuprofen 400mg, Rest, Ice, Knee Brace', 'COMPLETED'),
(4, 'VST-2026-004', 4, 7, '2026-10-15 02:45:00', 'Laceration on right forearm', 'Wound suture (4 stitches), Tetanus booster', 'COMPLETED'),
(5, 'VST-2026-005', 5, 4, '2026-10-18 10:00:00', 'Seasonal Bronchitis', 'Amoxicillin 500mg TID 7 days', 'COMPLETED'),
(6, 'VST-2026-006', 6, 6, '2026-10-22 15:30:00', 'Contact Eczema Flare-up', 'Hydrocortisone 1% topical ointment', 'COMPLETED'),
(7, 'VST-2026-007', 7, 5, '2026-10-25 08:30:00', 'Post-Op Oncology Surveillance', 'Blood lab panel order, Follow-up 6 months', 'COMPLETED'),
(8, 'VST-2026-008', 8, 8, '2026-10-28 13:45:00', 'Acid Reflux / GERD', 'Omeprazole 20mg daily before breakfast', 'COMPLETED'),
(9, 'VST-2026-009', 9, 9, '2026-11-02 11:00:00', 'Asthma Exacerbation', 'Albuterol inhaler 2 puffs Q4H PRN', 'OPEN'),
(10, 'VST-2026-010', 10, 10, '2026-11-05 16:15:00', 'Abdominal Hernia Consultation', 'Ultrasound imaging scheduled, Prep surgery', 'OPEN'),
(11, 'VST-2026-011', 1, 1, '2026-11-08 10:30:00', 'Hypertension Routine Follow-up', 'Continue Metoprolol, BP check 122/80', 'OPEN'),
(12, 'VST-2026-012', 3, 3, '2026-11-10 14:30:00', 'Knee Rehabilitation Review', 'Referral to Physical Therapy 2x weekly', 'OPEN');

-- Insert 12 Billings (Minimum 10 rows, non-negative amounts, default status OPEN)
INSERT INTO billings (bill_id, bill_number, visit_id, bill_amount, discount_amount, payment_status) VALUES
(1, 'INV-2026-001', 1, 450.00, 50.00, 'PAID'),
(2, 'INV-2026-002', 2, 980.00, 100.00, 'PAID'),
(3, 'INV-2026-003', 3, 320.00, 20.00, 'PAID'),
(4, 'INV-2026-004', 4, 650.00, 0.00, 'PAID'),
(5, 'INV-2026-005', 5, 210.00, 10.00, 'PAID'),
(6, 'INV-2026-006', 6, 280.00, 0.00, 'PAID'),
(7, 'INV-2026-007', 7, 1200.00, 150.00, 'PAID'),
(8, 'INV-2026-008', 8, 390.00, 40.00, 'PAID'),
(9, 'INV-2026-009', 9, 260.00, 0.00, 'OPEN'),
(10, 'INV-2026-010', 10, 850.00, 50.00, 'OPEN'),
(11, 'INV-2026-011', 11, 180.00, 0.00, 'OPEN'),
(12, 'INV-2026-012', 12, 220.00, 20.00, 'OPEN');

-- ----------------------------------------------------------------------------
-- 2. BASIC RETRIEVAL: PATIENTS IN A GIVEN MONTH & DOCTORS BY DEPARTMENT
-- ----------------------------------------------------------------------------

-- Query A: Retrieve all patients who visited in October 2026
SELECT 
    v.visit_code,
    v.visit_date,
    p.patient_code,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.phone AS patient_phone,
    CONCAT(d.first_name, ' ', d.last_name) AS attending_doctor,
    dept.department_name,
    v.diagnosis,
    b.net_amount,
    b.payment_status
FROM visits v
JOIN patients p ON v.patient_id = p.patient_id
JOIN doctors d ON v.doctor_id = d.doctor_id
JOIN departments dept ON d.department_id = dept.department_id
JOIN billings b ON v.visit_id = b.visit_id
WHERE v.visit_date >= '2026-10-01 00:00:00' 
  AND v.visit_date < '2026-11-01 00:00:00'
ORDER BY v.visit_date ASC;

-- Query B: Retrieve all doctors grouped by their department
SELECT 
    dept.department_id,
    dept.department_name,
    dept.building_floor,
    dept.head_of_department,
    d.doctor_code,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization,
    d.phone AS doctor_phone
FROM departments dept
LEFT JOIN doctors d ON dept.department_id = d.department_id
ORDER BY dept.department_name, doctor_name;

-- ----------------------------------------------------------------------------
-- 3. USER-DEFINED DATABASE & TABLE LIFECYCLE (DOCUMENTATION & COMMANDS)
-- ----------------------------------------------------------------------------
-- Step A: Create sandbox database
CREATE DATABASE IF NOT EXISTS hospital_sandbox_temp;
USE hospital_records_db;

-- Step B: Rename a table demonstration
-- Example: ALTER TABLE billings RENAME TO patient_invoices;
-- ALTER TABLE patient_invoices RENAME TO billings;

-- Step C: Drop and recreate sandbox database
DROP DATABASE IF EXISTS hospital_sandbox_temp;
CREATE DATABASE hospital_sandbox_temp;
DROP DATABASE hospital_sandbox_temp;
