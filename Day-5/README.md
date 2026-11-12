# Day 5 – Databases, Normalisation and Data Definition (MySQL 8.4 LTS)

**Author:** Pratap Sakthivel  
**Repository:** [PratapSakthivel/Hexaware-Homeworks](https://github.com/PratapSakthivel/Hexaware-Homeworks)  
**Topics Covered:** Introduction to Databases · Normalisation (1NF, 2NF, 3NF, BCNF) · Managing Databases · Managing Tables · DML and Basic Retrieval  

---

## Directory Overview

```
Day-5/
├── README.md                                   # Master overview of Day 5 assignments
├── Set1_RetailInventoryManagement/             # Set 1: Retail Inventory Management
│   ├── schema.sql                              # 3NF InnoDB schema with PK, FK, CHECK, UNIQUE, DEFAULT
│   ├── seed_data.sql                           # 10+ rows/table, failing inserts, UPDATE/DELETE before-after
│   └── failing_inserts_and_er_report.md        # ER diagram, anomalies analysis & failure evidence
│
├── Set2_BankBranchAccounts/                    # Set 2: Bank Branch Accounts
│   ├── schema.sql                              # 3NF/BCNF schema with AUTO_INCREMENT, DECIMAL(15,2), CHECK
│   ├── seed_data.sql                           # 10+ rows/table, complex filtering (AND/OR/IN/BETWEEN/LIKE), DROP/TRUNCATE/DELETE
│   └── data_types_and_er_report.md             # ER diagram, data type justifications & DROP vs TRUNCATE vs DELETE
│
└── Set3_HospitalPatientRecords/                # Set 3: Hospital Patient Records
    ├── schema.sql                              # 3NF schema (Patient, Doctor, Dept, Visit, Billing)
    ├── seed_data.sql                           # 10+ rows/table, temporal queries, database lifecycle demo
    └── sql_vs_nosql_and_er_report.md           # ER diagram, decomposition steps & SQL vs NoSQL comparison table
```

---

## Summary of Completed Sets & Deliverables

### 1. Set 1 – Retail Inventory Management
- **Business Problem:** A retailer keeps stock in a single un-normalized spreadsheet (`SKU, product_name, category, supplier_name, supplier_phone, warehouse, quantity, reorder_level`).
- **Decomposition:** Normalised to 3NF across 4 tables: `suppliers`, `warehouses`, `products`, and `inventory`.
- **Key Constraints:** `InnoDB` engine, `quantity >= 0`, `reorder_level >= 0`, `ON DELETE RESTRICT`, `ON UPDATE CASCADE`.
- **Deliverables:**
  - [`schema.sql`](./Set1_RetailInventoryManagement/schema.sql)
  - [`seed_data.sql`](./Set1_RetailInventoryManagement/seed_data.sql)
  - [`failing_inserts_and_er_report.md`](./Set1_RetailInventoryManagement/failing_inserts_and_er_report.md) (ER diagram, insert/update/delete anomalies, evidence for 4 failing inserts: duplicate PK, missing FK parent, negative quantity check, and null in mandatory column).

---

### 2. Set 2 – Bank Branch Accounts
- **Business Problem:** Bank branch tracks accounts in a de-normalised sheet (`customer, address, account_number, account_type, branch, relationship_manager, balance`).
- **Decomposition:** Normalised to 3NF/BCNF across 4 tables: `branches`, `relationship_managers`, `customers`, and `accounts`.
- **Key Constraints:** `AUTO_INCREMENT`, `UNIQUE(account_number)`, `CHECK(balance >= 0.00)`, `CHECK(account_type IN (...))`.
- **Data Type Justification:** `DECIMAL(15,2)` selected for balance to eliminate IEEE 754 floating point rounding errors in financial transactions.
- **Deep-Dive Concepts:** Differentiated `DROP`, `TRUNCATE`, and `DELETE` on transactional rollback and `AUTO_INCREMENT` reset. Implemented complex retrieval using `AND`, `OR`, `IN`, `BETWEEN`, and `LIKE`.
- **Deliverables:**
  - [`schema.sql`](./Set2_BankBranchAccounts/schema.sql)
  - [`seed_data.sql`](./Set2_BankBranchAccounts/seed_data.sql)
  - [`data_types_and_er_report.md`](./Set2_BankBranchAccounts/data_types_and_er_report.md)

---

### 3. Set 3 – Hospital Patient Records
- **Business Problem:** Hospital stores clinical visits in one wide sheet (`patient, address, doctor, department, visit_date, diagnosis, prescription, bill_amount`).
- **Decomposition:** Decomposed into 3NF across 5 distinct entities: `departments`, `patients`, `doctors`, `visits`, and `billings`.
- **Key Constraints:** Valid visit dates, `CHECK(bill_amount >= 0.00)`, default status of `'OPEN'`.
- **Database & Table Lifecycle:** Step-by-step documentation of physical `.ibd` files and data dictionary changes during `CREATE DATABASE`, `ALTER TABLE ... RENAME`, and `DROP DATABASE`.
- **SQL vs NoSQL Comparison:** Comprehensive evaluation matrix contrasting MySQL 8.4 against Document NoSQL across Structure, Consistency, Scalability, and Healthcare Use Cases.
- **Deliverables:**
  - [`schema.sql`](./Set3_HospitalPatientRecords/schema.sql)
  - [`seed_data.sql`](./Set3_HospitalPatientRecords/seed_data.sql)
  - [`sql_vs_nosql_and_er_report.md`](./Set3_HospitalPatientRecords/sql_vs_nosql_and_er_report.md)
