package com.hexaware.banking.task2;

import com.hexaware.banking.model.Transaction;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Task 2: Statement Sorting & Stability Analysis
 * Implements Insertion Sort and Merge Sort by posting date.
 * Explains sorting stability and demonstrates why it is vital in banking
 * when transactions share the same timestamp (e.g., Deposit before Debit).
 */
public class StatementSortBenchmark {

    /**
     * Insertion Sort: Stable O(n^2) sorting algorithm.
     * Preserves relative order of equal elements by using strictly greater-than '>' comparison.
     */
    public static void insertionSort(Transaction[] arr) {
        int n = arr.length;
        for (int i = 1; i < n; i++) {
            Transaction key = arr[i];
            int j = i - 1;
            // Only move arr[j] if it is strictly AFTER key's posting date (preserves stability)
            while (j >= 0 && arr[j].getPostingDate().isAfter(key.getPostingDate())) {
                arr[j + 1] = arr[j];
                j--;
            }
            arr[j + 1] = key;
        }
    }

    /**
     * Merge Sort: Stable O(n log n) divide-and-conquer sorting algorithm.
     * Preserves relative order by favoring left sub-array on ties (<=).
     */
    public static void mergeSort(Transaction[] arr, int left, int right) {
        if (left < right) {
            int mid = left + (right - left) / 2;
            mergeSort(arr, left, mid);
            mergeSort(arr, mid + 1, right);
            merge(arr, left, mid, right);
        }
    }

    private static void merge(Transaction[] arr, int left, int mid, int right) {
        int n1 = mid - left + 1;
        int n2 = right - mid;

        Transaction[] L = new Transaction[n1];
        Transaction[] R = new Transaction[n2];

        System.arraycopy(arr, left, L, 0, n1);
        System.arraycopy(arr, mid + 1, R, 0, n2);

        int i = 0, j = 0, k = left;
        while (i < n1 && j < n2) {
            // Stable condition: if L[i] <= R[j], pick L[i] to preserve original order
            if (!L[i].getPostingDate().isAfter(R[j].getPostingDate())) {
                arr[k++] = L[i++];
            } else {
                arr[k++] = R[j++];
            }
        }

        while (i < n1) arr[k++] = L[i++];
        while (j < n2) arr[k++] = R[j++];
    }

    public static void runDemo(List<Transaction> allTransactions) {
        System.out.println("================================================================================");
        System.out.println("   TASK 2: STATEMENT SORTING BY POSTING DATE & STABILITY DEMONSTRATION");
        System.out.println("================================================================================");

        // Filter transactions for a single customer account with multiple transactions
        String targetAccount = "ACC-1042";
        List<Transaction> accountTxns = new ArrayList<>();
        for (Transaction t : allTransactions) {
            if (t.getAccountId().equals(targetAccount)) {
                accountTxns.add(t);
            }
        }

        // If not enough transactions for that account, take a subset of 10 transactions
        if (accountTxns.size() < 5) {
            accountTxns = new ArrayList<>(allTransactions.subList(0, 10));
        }

        System.out.printf("Reviewing Statement for Account: %s (%d transactions)%n%n", targetAccount, accountTxns.size());

        // ---------------------------------------------------------------------
        // PART A: DEMONSTRATING SORTING STABILITY WITH IDENTICAL TIMESTAMPS
        // ---------------------------------------------------------------------
        System.out.println("--- Part A: Why Stability Matters in Banking (Deposit vs Debit Conflict) ---");
        LocalDateTime sharedTime = LocalDateTime.of(2026, 10, 29, 14, 30, 0);

        // Transaction 1: Direct Payroll Deposit of $1,000 (Sequence 1)
        Transaction deposit = new Transaction(5001L, targetAccount, 1000.00, "Employer Payroll Deposit", sharedTime, 1);
        // Transaction 2: Mortgage Payment Debit of $950 (Sequence 2)
        Transaction debit = new Transaction(5002L, targetAccount, -950.00, "Mortgage Debit Transfer", sharedTime, 2);

        // Input statement where initial balance is $50.
        // If Deposit (Seq 1) is processed first: $50 + $1000 = $1050 -> $1050 - $950 = $100 (HEALTHY).
        // If an UNSTABLE sort reverses them (Seq 2 before Seq 1): $50 - $950 = -$900 -> OVERDRAFT PENALTY ($35 FEE)!
        Transaction[] stabilityTest = {deposit, debit};

        System.out.println("Initial Transaction Stream (Both posted at EXACT same second: 14:30:00):");
        System.out.printf("  [Seq 1] %s -> Initial Balance: $50 + $1000 = $1050%n", deposit);
        System.out.printf("  [Seq 2] %s -> Subsequent Debit: $1050 - $950 = $100 (No Overdraft)%n", debit);

        Transaction[] arrInsertion = stabilityTest.clone();
        insertionSort(arrInsertion);

        Transaction[] arrMerge = stabilityTest.clone();
        mergeSort(arrMerge, 0, arrMerge.length - 1);

        System.out.println("\nResult after Insertion Sort (Stable):");
        for (Transaction t : arrInsertion) {
            System.out.printf("  - %s (Original Sequence: %d)%n", t, t.getOriginalSequence());
        }

        System.out.println("Result after Merge Sort (Stable):");
        for (Transaction t : arrMerge) {
            System.out.printf("  - %s (Original Sequence: %d)%n", t, t.getOriginalSequence());
        }

        boolean stable = (arrInsertion[0].getOriginalSequence() == 1 && arrMerge[0].getOriginalSequence() == 1);
        System.out.printf("%nStability Verification: Relative chronological sequence preserved? -> %s%n",
                stable ? "YES (STABLE - No illegal overdrafts triggered)" : "NO (UNSTABLE)");

        // ---------------------------------------------------------------------
        // PART B: BENCHMARK ON 5,000 STATEMENT TRANSACTIONS
        // ---------------------------------------------------------------------
        System.out.println("\n--- Part B: Performance Benchmark on 5,000 Customer Records ---");
        int testCount = Math.min(5000, allTransactions.size());
        Transaction[] benchmarkSample = allTransactions.subList(0, testCount).toArray(new Transaction[0]);

        Transaction[] benchInsertion = benchmarkSample.clone();
        Transaction[] benchMerge = benchmarkSample.clone();

        long t0 = System.currentTimeMillis();
        insertionSort(benchInsertion);
        long timeInsertion = System.currentTimeMillis() - t0;

        long t1 = System.currentTimeMillis();
        mergeSort(benchMerge, 0, benchMerge.length - 1);
        long timeMerge = System.currentTimeMillis() - t1;

        System.out.printf("  - Insertion Sort [O(n^2)]      : %d ms%n", timeInsertion);
        System.out.printf("  - Merge Sort     [O(n log n)]  : %d ms (Speedup: %.1fx)%n%n",
                timeMerge, (double) Math.max(1, timeInsertion) / Math.max(1, timeMerge));
    }
}
