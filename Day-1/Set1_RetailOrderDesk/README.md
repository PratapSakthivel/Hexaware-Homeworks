# Set 1 – Retail Order Desk

Enterprise Order Processing, Algorithm Benchmarking, and Data Structures Suite for Hexaware Homeworks.

## Directory Structure
```
Set1_RetailOrderDesk/
├── COMPLEXITY_AND_RATIONALE.md   # Required 1-page note covering complexity & data-structure rationale
├── console_output.txt            # Complete captured console output of all 5 tasks
├── data/
│   └── orders.csv                # 50,000 order records (auto-generated if missing)
├── src/
│   └── com/hexaware/retail/
│       ├── Main.java             # Master runner executing all 5 tasks
│       ├── model/
│       │   ├── Order.java        # Order model (orderId, customerId, amount, createdAt)
│       │   └── OrderEdit.java    # Edit encapsulation for Undo stack
│       ├── task1/
│       │   └── SearchBenchmark.java   # Linear vs Binary search benchmark on 50,000 records
│       ├── task2/
│       │   └── SortBenchmark.java     # Bubble Sort, Merge Sort, TimSort, 3-pass paper trace
│       ├── task3/
│       │   └── DuplicateDetector.java # Hash-based duplicate detection (customerId, amount, minute)
│       ├── task4/
│       │   ├── CustomStack.java       # Custom LIFO stack with dynamic resizing
│       │   ├── CustomQueue.java       # Custom FIFO queue with circular buffer
│       │   └── DispatchAndUndoDemo.java# Undo order edit & dispatch line simulation + benchmarks
│       ├── task5/
│       │   └── RefundCalculator.java  # Refund coin change: Greedy vs DP + counterexamples
│       └── util/
│           └── CsvOrderGenerator.java # High-performance CSV generator & loader
├── run.bat                       # Windows batch script to compile & run
└── run.ps1                       # PowerShell script to compile & run
```

## How to Run

### Option 1: Using the PowerShell script (Recommended)
```powershell
.\run.ps1
```

### Option 2: Using the Command Prompt batch script
```cmd
run.bat
```

### Option 3: Manual Compilation & Execution
```powershell
& 'C:\Program Files\Java\jdk-25.0.5.0.3\bin\javac.exe' -d bin -sourcepath src src/com/hexaware/retail/Main.java
& 'C:\Program Files\Java\jdk-25.0.5.0.3\bin\java.exe' -cp bin com.hexaware.retail.Main
```

## Tasks Overview
1. **Task 1 - Retrieval Benchmark**: Evaluates Linear Search vs Binary Search on 50,000 orders across best, average, worst, and missing cases + 1,000 random query batch.
2. **Task 2 - Sorting Benchmark**: Bubble Sort ($O(n^2)$) vs Merge Sort ($O(n \log n)$) vs `Arrays.sort()` (TimSort) on 10,000 orders + 3-pass paper trace.
3. **Task 3 - Duplicate Order Detection**: Detects duplicate orders (same customerId & amount within the same minute) using a `HashMap` composite key in $O(n)$ time.
4. **Task 4 - Stack & Queue Operations**: Custom `Stack` (LIFO) for 'undo last order edit' and Custom `Queue` (FIFO) for warehouse dispatch line, with empirical comparison against `ArrayDeque`, legacy `Stack`, and `LinkedList`.
5. **Task 5 - Refund Coin Minimization**: Greedy approach vs Dynamic Programming (Bottom-Up Tabulation) for standard currency and counterexample failure sets ($[1, 3, 4]$ with target $6$).
