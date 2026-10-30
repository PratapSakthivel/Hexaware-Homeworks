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
