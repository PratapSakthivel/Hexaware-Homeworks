# Set 3: Insurance Premium Bands – Execution Output & JVM Memory Model

## 1. Output for Eight Applicants with Labeled Break Demonstration

```text
=========================================================================================
                    INSURANCE UNDERWRITING & PREMIUM BANDS ENGINE                        
=========================================================================================

APP ID   | NAME             | BMI   | CATEGORY     | LOAD %   | BASE RATE    | FINAL PREMIUM  | STATUS
-----------------------------------------------------------------------------------------------------------------
INS-001  | Kiran Desai      | 22.2  | NORMAL       | 0.0%     | ₹8500.00     | ₹8500.00       | APPROVED_STANDARD
INS-002  | Manoj Bajpayee   | 28.4  | OVERWEIGHT   | 30.0%    | ₹14000.00    | ₹18200.00      | APPROVED_STANDARD
INS-003  | Alia Bhatt       | 19.1  | NORMAL       | 0.0%     | ₹6500.00     | ₹6500.00       | APPROVED_STANDARD
INS-004  | Vikramaditya     | 33.9  | OBESE        | 25.0%    | ₹24000.00    | ₹30000.00      | APPROVED_STANDARD
INS-005  | Sunil Chhetri    | 23.4  | NORMAL       | 0.0%     | ₹14000.00    | ₹14000.00      | APPROVED_STANDARD
INS-006  | Geeta Phogat     | 24.0  | NORMAL       | 0.0%     | ₹14000.00    | ₹14000.00      | APPROVED_STANDARD
INS-007  | Rajnath Singh    | N/A   | INELIGIBLE   | 0.0%     | 0.00         | 0.00           | FAILED: Age 76 outside insurable limits (18-70). [LABELED BREAK TRIGGERED]

[BATCH HALTED] Labeled break invoked. Remaining applications postponed for manual review.
-----------------------------------------------------------------------------------------------------------------
```
*Proof of Labeled Break:* Notice that Applicant `INS-008` (Zoya Akhtar) is never evaluated because the labeled loop `BATCH_EVALUATION` terminates immediately upon detecting `INS-007` (Age 76 > 70).

---

## 2. JVM Memory Model Explanation: Stack vs Heap & Garbage Collection

In Java (JDK 21 / JDK 25 LTS), memory is architected into distinct runtime data areas:

### 1. The Stack Memory (Thread-Local Execution)
- **What is Stored Here:**
  - Method stack frames created during thread execution.
  - Primitive local variables (`int age`, `double bmi`, `boolean isSmoker`).
  - Reference pointers (e.g. the 64-bit object reference address variable `app` pointing to an `Applicant` instance on the Heap).
- **Lifecycle & Characteristics:**
  - Extremely fast memory access (L1/L2 CPU cache friendly).
  - Allocation and deallocation occur automatically in LIFO order as methods are pushed and popped. No garbage collector runs on the Stack.

### 2. The Heap Memory (Shared Dynamic Object Allocation)
- **What is Stored Here:**
  - All Java objects, records, and array structures (`new Applicant(...)`, `new PolicyQuote(...)`, `List.of(...)`, `String` character arrays).
  - Instance variables and fields associated with those objects.
- **Lifecycle & Characteristics:**
  - Shared globally across all JVM threads.
  - Slower access relative to the stack; requires reference dereferencing.

### 3. What Happens When Objects Are No Longer Reachable?
1. **Scope Exit:** In `for (var app : applicants)`, during each loop iteration, a `PolicyQuote` record object is instantiated on the Heap. Once printed to the console and the loop advances to the next iteration, the local stack reference pointer moves.
2. **Loss of Reachability:** If no active root references (GC Roots: static fields, active stack frame local variables, JNI references) can reach the `PolicyQuote` object, it transitions to the **Unreachable / Eligible for Garbage Collection** state.
3. **Garbage Collection (ZGC / G1GC in modern JDKs):**
   - The modern generational garbage collector scans the heap concurrently without long "stop-the-world" pauses.
   - It identifies unreachable memory blocks, reclaims the heap memory, and compacts free space for subsequent allocations.
