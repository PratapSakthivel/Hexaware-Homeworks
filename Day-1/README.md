# Day 1 – Problem Solving Techniques & Data Structures

This directory contains the complete implementations, benchmark outputs, and theoretical complexity reports for all three problem sets assigned on **Day 1 (29 October 2026)**.

---

## Directory Navigation

### 1. [Set 1 – Retail Order Desk](./Set1_RetailOrderDesk/)
- **Business Scenario:** Support agents look up orders instantly, warehouse ranks orders for dispatch, and finance flags duplicate submissions.
- **Tasks:**
  1. Retrieval Benchmark (Linear Search vs Binary Search on 50,000 records).
  2. Sorting Algorithms ($O(n^2)$ Bubble Sort vs $O(n \log n)$ Merge Sort on 10,000 records + 3-pass paper trace).
  3. Duplicate Order Detection via `HashMap` composite key in $O(n)$ time.
  4. Custom Resizing `Stack` ('undo last order edit') and Circular `Queue` ('dispatch line') vs library equivalents.
  5. Refund Note Minimization (Greedy vs Dynamic Programming + counterexample proof).
- **Report:** [COMPLEXITY_AND_RATIONALE.md](./Set1_RetailOrderDesk/COMPLEXITY_AND_RATIONALE.md)

---

### 2. [Set 2 – Retail Banking Transaction Review](./Set2_RetailBankingTransactionReview/)
- **Business Scenario:** Operations team reviews daily card transactions, statement sorting, and duplicate charge alerts.
- **Tasks:**
  1. Transaction ID Search on 100,000 sorted records (Counting comparisons for best, average, worst cases).
  2. Customer Statement Sorting by posting date using Insertion Sort and Merge Sort + Sorting Stability proof.
  3. Duplicate Posting Identification (same account, amount, merchant within 60 seconds).
  4. Manual-Review Backlog Queue (FIFO) and Adjustment Reversal Stack (LIFO) implemented from scratch.
  5. Finding Extreme Amounts (Min/Max) using Divide-and-Conquer ($1.5n$ comparisons) vs Brute-force ($2n$).
- **Report:** [COMPLEXITY_AND_RATIONALE.md](./Set2_RetailBankingTransactionReview/COMPLEXITY_AND_RATIONALE.md)

---

### 3. [Set 3 – Hospital Appointment Desk](./Set3_HospitalAppointmentDesk/)
- **Business Scenario:** Multidisciplinary hospital reception search, urgency triage sorting, double-booking prevention, and physician shift scheduling.
- **Tasks:**
  1. Patient ID Search over 20,000 patient records (1,000 look-ups benchmark).
  2. Appointment Triage Sorting by urgency level and arrival time (Selection Sort vs Quick Sort + typed 3-pass trace).
  3. Double-Booked Slot Detection via `HashSet` in $O(n)$ time vs quadratic list scan.
  4. Walk-in Token Line Queue and Recent Patients Chart History Stack from scratch.
  5. Doctor Shift Scheduling using Dynamic Programming (Weighted Interval Scheduling) vs Greedy.
- **Report:** [COMPLEXITY_AND_RATIONALE.md](./Set3_HospitalAppointmentDesk/COMPLEXITY_AND_RATIONALE.md)
