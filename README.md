# Hexaware Homeworks & Assignments Repository

**Student / Author:** Pratap Sakthivel  
**GitHub:** [PratapSakthivel](https://github.com/PratapSakthivel)  
**Email:** pratapssakthivel@gmail.com  

---

## Repository Structure

All assignments and training problem sets are organized systematically by training day:

```
Hexaware-Homeworks/
├── Day-1/
│   ├── Set1_RetailOrderDesk/               # Set 1: Online Retail Order Desk DSA
│   ├── Set2_RetailBankingTransactionReview/ # Set 2: Retail Banking Transaction Review
│   └── Set3_HospitalAppointmentDesk/       # Set 3: Hospital Appointment Desk
├── Day_02/                                 # Day 2: Insurance Claims Processing DSA
├── Day-5/                                  # Day 5: Databases, Normalisation and Data Definition (MySQL 8.4)
│   ├── Set1_RetailInventoryManagement/     # Set 1: Retail Inventory Management
│   ├── Set2_BankBranchAccounts/            # Set 2: Bank Branch Accounts
│   └── Set3_HospitalPatientRecords/        # Set 3: Hospital Patient Records
└── .gitignore
```

---

## Day 1 – Problem Solving Techniques & Data Structures (29 Oct 2026)

All three comprehensive problem sets for **Day 1** are housed inside the [`Day-1/`](./Day-1/) folder:

| Module | Business Domain | Key Algorithmic Concepts Implemented | Documentation |
| :--- | :--- | :--- | :---: |
| **[Set 1: Retail Order Desk](./Day-1/Set1_RetailOrderDesk)** | E-Commerce Retail (50,000 orders/day) | Linear vs Binary Search, Bubble Sort vs Merge Sort (3-pass paper trace), Hash-based duplicate order detection ($O(n)$), Custom Resizing Stack & Circular Queue, Greedy vs DP coin change refund. | [View Note](./Day-1/Set1_RetailOrderDesk/COMPLEXITY_AND_RATIONALE.md) |
| **[Set 2: Retail Banking](./Day-1/Set2_RetailBankingTransactionReview)** | Core Banking (100,000 txns/day) | Binary Search on 100k IDs, Insertion vs Merge Sort with Sorting Stability proof, Duplicate postings ($\le 60$s), Custom Queue (Audit backlog) & Stack (Reverse adjustment), Divide-and-Conquer min/max amount. | [View Note](./Day-1/Set2_RetailBankingTransactionReview/COMPLEXITY_AND_RATIONALE.md) |
| **[Set 3: Hospital Appointment](./Day-1/Set3_HospitalAppointmentDesk)** | Healthcare Roster (20,000 patients) | Patient ID search over 20k records, Multi-key Urgency & Arrival sorting (Selection vs Quick Sort with 3-pass trace), Double-booking detection ($O(n)$ HashSet vs $O(n^2)$ list scan), Walk-in Queue & Stack, Doctor shift scheduling (Weighted Interval DP). | [View Note](./Day-1/Set3_HospitalAppointmentDesk/COMPLEXITY_AND_RATIONALE.md) |

Each set contains complete standalone Java source code, high-volume datasets, full captured console outputs, complexity analysis documents, and one-click execution scripts (`run.ps1` and `run.bat`).

---

## Day 2 – Insurance Claims Processing (Java)

The Day 2 assignment is located in the [`Day_02/`](./Day_02/) folder:

| Module | Business Domain | Key Algorithmic Concepts Implemented | Documentation |
| :--- | :--- | :--- | :---: |
| **[Day 2: Insurance Claims Processing](./Day_02)** | Insurance Claims | 1. Claim ID Binary Search Tree (BST) with in-order/pre-order/post-order traversals.<br>2. Hashing for duplicate claim detection (normalized policy + incident date).<br>3. Approval-stage Graph (BFS shortest path & DFS cycle detection).<br>4. Sliding Window (Consecutive days strictly above 100 claims).<br>5. Two Pointers (Merging sorted regional claim lists in $O(n+m)$). | [View Readme](./Day_02/README.md) & [Complexity Table](./Day_02/complexity_table.txt) |

---

## Day 5 – Databases, Normalisation and Data Definition – MySQL 8.4 LTS

All three comprehensive database engineering sets for **Day 5** are housed inside the [`Day-5/`](./Day-5/) folder:

| Module | Business Domain | Key Database Concepts & Deliverables | Documentation |
| :--- | :--- | :--- | :---: |
| **[Set 1: Retail Inventory Management](./Day-5/Set1_RetailInventoryManagement)** | Retail Inventory (Spreadsheet to 3NF) | 3NF InnoDB schema (`suppliers`, `warehouses`, `products`, `inventory`), PK/FK/CHECK/UNIQUE constraints, ON DELETE RESTRICT / ON UPDATE CASCADE, 4 failing insert demonstrations, UPDATE/DELETE before-after evidence, `information_schema` table profiling. | [View Report](./Day-5/Set1_RetailInventoryManagement/failing_inserts_and_er_report.md) |
| **[Set 2: Bank Branch Accounts](./Day-5/Set2_BankBranchAccounts)** | Core Banking Accounts | 3NF/BCNF schema (`branches`, `relationship_managers`, `customers`, `accounts`), AUTO_INCREMENT, DECIMAL(15,2) financial justification, DROP vs TRUNCATE vs DELETE comparative analysis on rollback and AUTO_INCREMENT, complex WHERE queries (AND, OR, IN, BETWEEN, LIKE), ALTER TABLE. | [View Report](./Day-5/Set2_BankBranchAccounts/data_types_and_er_report.md) |
| **[Set 3: Hospital Patient Records](./Day-5/Set3_HospitalPatientRecords)** | Clinical Visits & Healthcare | 3NF decomposition (`departments`, `patients`, `doctors`, `visits`, `billings`), non-negative bill check, default status OPEN, database & table file lifecycle analysis (`.ibd` behavior on rename/drop), monthly visit & department doctor queries, SQL vs NoSQL comparison table. | [View Report](./Day-5/Set3_HospitalPatientRecords/sql_vs_nosql_and_er_report.md) |


