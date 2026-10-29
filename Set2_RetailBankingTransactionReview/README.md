# Set 2 – Retail Banking Transaction Review

Core Banking Transaction Processing, Audit Search, and Algorithmic Review Suite.

## Project Structure
```
Set2_RetailBankingTransactionReview/
├── COMPLEXITY_AND_RATIONALE.md   # Complexity table & data-structure justifications
├── console_output.txt            # Complete captured execution log for all 5 tasks
├── data/
│   └── transactions.csv          # 100,000 card transactions dataset
├── src/
│   └── com/hexaware/banking/
│       ├── Main.java             # Master runner executing all 5 tasks
│       ├── model/
│       │   ├── Transaction.java  # Transaction model (id, accountId, amount, merchant, date, seq)
│       │   └── Adjustment.java   # Account fee waiver / adjustment model for stack
│       ├── task1/
│       │   └── TransactionSearchBenchmark.java # Binary vs Linear search on 100k IDs
│       ├── task2/
│       │   └── StatementSortBenchmark.java     # Insertion vs Merge sort + Stability proof
│       ├── task3/
│       │   └── DuplicatePostingDetector.java   # Hash-based duplicate posting detector (<= 60s)
│       ├── task4/
│       │   ├── CustomQueue.java                # Custom FIFO queue without library collections
│       │   ├── CustomStack.java                # Custom LIFO stack without library collections
│       │   └── ReviewBacklogAndReversalDemo.java# Audit backlog & adjustment reversal simulation
│       ├── task5/
│       │   └── ExtremeAmountFinder.java        # Divide-and-Conquer min/max amount finder
│       └── util/
│           └── TransactionGenerator.java       # High-performance CSV transaction generator
├── run.bat                       # One-click Windows CMD build & runner
└── run.ps1                       # One-click PowerShell build & runner
```

## How to Run

### PowerShell:
```powershell
.\run.ps1
```

### Windows CMD:
```cmd
run.bat
```

### Manual:
```powershell
& 'C:\Program Files\Java\jdk-25.0.5.0.3\bin\javac.exe' -d bin -sourcepath src src/com/hexaware/banking/Main.java
& 'C:\Program Files\Java\jdk-25.0.5.0.3\bin\java.exe' -cp bin com.hexaware.banking.Main
```
