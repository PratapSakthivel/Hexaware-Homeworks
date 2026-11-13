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
├── Day-3/                                  # Day 3: Agile and Scrum Foundations & Backlog Workshop
│   ├── Set1_OnlineGroceryDelivery/         # Set 1: Online Grocery Delivery App
│   ├── Set2_InsuranceClaimsPortal/         # Set 2: Insurance Claims Portal
│   └── Set3_HospitalAppointmentBooking/    # Set 3: Hospital Appointment Booking App
├── Day-5/                                  # Day 5: Databases, Normalisation and Data Definition (MySQL 8.4)
│   ├── Set1_RetailInventoryManagement/     # Set 1: Retail Inventory Management
│   ├── Set2_BankBranchAccounts/            # Set 2: Bank Branch Accounts
│   └── Set3_HospitalPatientRecords/        # Set 3: Hospital Patient Records
├── Day-6/                                  # Day 6: Functions, Aggregation, Grouping and Joins (MySQL 8.4)
│   ├── Set1_RetailSalesReporting/          # Set 1: Retail Sales Reporting
│   ├── Set2_InsurancePolicyReporting/      # Set 2: Insurance Policy Reporting
│   └── Set3_TelecomUsageAndBilling/        # Set 3: Telecom Usage and Billing
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

## Day 3 – Agile and Scrum – Foundations and Backlog Workshop

All three comprehensive Agile backlog engineering sets for **Day 3** are housed inside the [`Day-3/`](./Day-3/) folder:

| Module | Business Domain | Key Agile / Scrum Deliverables | Documentation |
| :--- | :--- | :--- | :---: |
| **[Set 1: Online Grocery Delivery](./Day-3/Set1_OnlineGroceryDelivery)** | E-Commerce Grocery Delivery | Product Vision, Scrum Roles & Anti-Patterns (PO, SM, Developers), 3 Epics, 12 User Stories, INVEST checklist rewrites, Given/When/Then acceptance criteria (including negative edge cases), MoSCoW prioritization, Planning Poker (48 pts), DoR and DoD. | [View Workshop Report](./Day-3/Set1_OnlineGroceryDelivery/README.md) |
| **[Set 2: Insurance Claims Portal](./Day-3/Set2_InsuranceClaimsPortal)** | Insurance Claims Self-Service | Product Vision, Half-page Waterfall vs Agile analysis, 4 Epics, 13 User Stories, vertical slicing vs horizontal architectural layering, First Notice of Loss (FNOL) Given/When/Then criteria, Planning Poker outlier discussion (51 pts), JIRA board workflow & DoD. | [View Workshop Report](./Day-3/Set2_InsuranceClaimsPortal/README.md) |
| **[Set 3: Hospital Appointment Booking](./Day-3/Set3_HospitalAppointmentBooking)** | Clinical Appointment Scheduling | Product Vision, Stakeholder-to-Scrum role mapping, 4 Epics, 12 User Stories, Given/When/Then criteria including concurrency conflicts ("slot already taken"), Story Points vs Hours conceptual analysis, Value vs Effort ranking (51 pts), 6-item DoR & DoD checklists. | [View Workshop Report](./Day-3/Set3_HospitalAppointmentBooking/README.md) |


---

## Day 5 – Databases, Normalisation and Data Definition – MySQL 8.4 LTS

All three comprehensive database engineering sets for **Day 5** are housed inside the [`Day-5/`](./Day-5/) folder:

| Module | Business Domain | Key Database Concepts & Deliverables | Documentation |
| :--- | :--- | :--- | :---: |
| **[Set 1: Retail Inventory Management](./Day-5/Set1_RetailInventoryManagement)** | Retail Inventory (Spreadsheet to 3NF) | 3NF InnoDB schema (`suppliers`, `warehouses`, `products`, `inventory`), PK/FK/CHECK/UNIQUE constraints, ON DELETE RESTRICT / ON UPDATE CASCADE, 4 failing insert demonstrations, UPDATE/DELETE before-after evidence, `information_schema` table profiling. | [View Report](./Day-5/Set1_RetailInventoryManagement/failing_inserts_and_er_report.md) |
| **[Set 2: Bank Branch Accounts](./Day-5/Set2_BankBranchAccounts)** | Core Banking Accounts | 3NF/BCNF schema (`branches`, `relationship_managers`, `customers`, `accounts`), AUTO_INCREMENT, DECIMAL(15,2) financial justification, DROP vs TRUNCATE vs DELETE comparative analysis on rollback and AUTO_INCREMENT, complex WHERE queries (AND, OR, IN, BETWEEN, LIKE), ALTER TABLE. | [View Report](./Day-5/Set2_BankBranchAccounts/data_types_and_er_report.md) |
| **[Set 3: Hospital Patient Records](./Day-5/Set3_HospitalPatientRecords)** | Clinical Visits & Healthcare | 3NF decomposition (`departments`, `patients`, `doctors`, `visits`, `billings`), non-negative bill check, default status OPEN, database & table file lifecycle analysis (`.ibd` behavior on rename/drop), monthly visit & department doctor queries, SQL vs NoSQL comparison table. | [View Report](./Day-5/Set3_HospitalPatientRecords/sql_vs_nosql_and_er_report.md) |

---

## Day 6 – Functions, Aggregation, Grouping and Joins – MySQL 8.4 LTS

All three comprehensive reporting and analytical query sets for **Day 6** are housed inside the [`Day-6/`](./Day-6/) folder:

| Module | Business Domain | Key SQL Analytics & Deliverables | Documentation |
| :--- | :--- | :--- | :---: |
| **[Set 1: Retail Sales Reporting](./Day-6/Set1_RetailSalesReporting)** | Retail Sales Analytics | 8 queries (top-5 products by revenue, month-wise sales, HAVING > 3 orders, avg basket value by city, orders without payment, inactive customers, category revenue share, peak sales day), string/date/math functions, NULL behavior analysis (`COUNT(*)`, `COUNT(col)`, `SUM`, `AVG`), WHERE vs HAVING. | [View Output & Analysis](./Day-6/Set1_RetailSalesReporting/output_and_analysis_report.md) |
| **[Set 2: Insurance Policy Reporting](./Day-6/Set2_InsurancePolicyReporting)** | Insurance Policy Administration | 8 queries (policies expiring in 30 days, premium by product, multi-policyholders, claim ratio by product, policies without claims, age-band premium analysis, monthly new policies, top-5 agents), masked policy numbers, loss ratio > 60% with HAVING, INNER/LEFT/CROSS join justifications. | [View Output & Analysis](./Day-6/Set2_InsurancePolicyReporting/output_and_analysis_report.md) |
| **[Set 3: Telecom Usage and Billing](./Day-6/Set3_TelecomUsageAndBilling)** | Telecom Usage & Revenue Assurance | 8 queries (call minutes by plan, data limit overage detection, month-wise revenue, overdue invoices > 15 days, dormant subscribers, ARPU by circle, plan popularity share, top-10 data consumers), NULL handling via `COALESCE` / `IFNULL`, revenue per plan and circle matrix. | [View Output & Analysis](./Day-6/Set3_TelecomUsageAndBilling/output_and_analysis_report.md) |



