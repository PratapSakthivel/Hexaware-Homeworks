package com.hexaware.banking.task1;

import com.hexaware.banking.model.Transaction;

import java.util.List;
import java.util.Random;

/**
 * Task 1: Binary Search vs Linear Search on 100,000 Sorted Transaction IDs.
 * Tracks comparison counts for Best, Average, and Worst cases.
 */
public class TransactionSearchBenchmark {

    public static class SearchMetrics {
        public final Transaction result;
        public final int comparisons;
        public final long durationNanos;

        public SearchMetrics(Transaction result, int comparisons, long durationNanos) {
            this.result = result;
            this.comparisons = comparisons;
            this.durationNanos = durationNanos;
        }
    }

    public static SearchMetrics binarySearch(Transaction[] arr, long targetId) {
        long start = System.nanoTime();
        int comparisons = 0;
        int low = 0;
        int high = arr.length - 1;
        Transaction found = null;

        while (low <= high) {
            comparisons++;
            int mid = low + (high - low) / 2;
            long midId = arr[mid].getTransactionId();

            if (midId == targetId) {
                found = arr[mid];
                break;
            } else if (midId < targetId) {
                low = mid + 1;
            } else {
                high = mid - 1;
            }
        }
        long duration = System.nanoTime() - start;
        return new SearchMetrics(found, comparisons, duration);
    }

    public static SearchMetrics linearSearch(Transaction[] arr, long targetId) {
        long start = System.nanoTime();
        int comparisons = 0;
        Transaction found = null;
        for (Transaction t : arr) {
            comparisons++;
            if (t.getTransactionId() == targetId) {
                found = t;
                break;
            }
        }
        long duration = System.nanoTime() - start;
        return new SearchMetrics(found, comparisons, duration);
    }

    public static void runBenchmark(List<Transaction> transactions) {
        System.out.println("================================================================================");
        System.out.println("   TASK 1: 100,000 TRANSACTION ID RETRIEVAL - BINARY SEARCH VS LINEAR SEARCH");
        System.out.println("================================================================================");
        System.out.printf("Total transactions in sorted audit registry: %,d%n%n", transactions.size());

        Transaction[] arr = transactions.toArray(new Transaction[0]);
        int n = arr.length;

        // Warm up JIT
        for (int i = 0; i < 2000; i++) {
            binarySearch(arr, arr[0].getTransactionId());
            linearSearch(arr, arr[0].getTransactionId());
        }

        // Test Cases:
        // 1. Best Case:
        //    - For Linear Search: first element arr[0] (1 comparison)
        //    - For Binary Search: middle element arr[(n-1)/2] (1 comparison)
        // 2. Average Case: Random element
        // 3. Worst Case (Found):
        //    - For Linear Search: last element arr[n-1] (100,000 comparisons)
        //    - For Binary Search: leaf element (e.g. arr[0] or arr[n-1] requiring 17 comparisons)
        // 4. Worst Case (Miss): Non-existent ID

        long idFirst = arr[0].getTransactionId();
        long idMid = arr[(n - 1) / 2].getTransactionId();
        long idLast = arr[n - 1].getTransactionId();
        long idMissing = 99_999_999L;

        System.out.println("+-----------------------------------------+----------------------+----------------------+------------+");
        System.out.println("| Scenario                                | Linear Search        | Binary Search        | Speedup    |");
        System.out.println("|                                         | Time (ns) | Comp.    | Time (ns) | Comp.    | Factor     |");
        System.out.println("+-----------------------------------------+-----------+----------+-----------+----------+------------+");

        testScenario("Best Case for Binary Search (Mid Element)", arr, idMid);
        testScenario("Best Case for Linear Search (1st Element)", arr, idFirst);
        testScenario("Worst Case (Last Element arr[n-1])", arr, idLast);
        testScenario("Worst Case Miss (Target Not in Array)", arr, idMissing);

        System.out.println("+-----------------------------------------+-----------+----------+-----------+----------+------------+");

        // 1,000 Random lookups
        System.out.println("\n--- Batch Test: 1,000 Random Auditor Lookups ---");
        Random rnd = new Random(42);
        long totalLinearTime = 0, totalBinaryTime = 0;
        int totalLinearComp = 0, totalBinaryComp = 0;
        int sample = 1000;

        for (int i = 0; i < sample; i++) {
            long targetId = arr[rnd.nextInt(n)].getTransactionId();
            SearchMetrics lin = linearSearch(arr, targetId);
            SearchMetrics bin = binarySearch(arr, targetId);
            totalLinearTime += lin.durationNanos;
            totalBinaryTime += bin.durationNanos;
            totalLinearComp += lin.comparisons;
            totalBinaryComp += bin.comparisons;
        }

        System.out.printf("Total Time for %,d queries:%n", sample);
        System.out.printf("  - Linear Search : %10.3f ms (Avg Comparisons: %,d)%n",
                totalLinearTime / 1e6, totalLinearComp / sample);
        System.out.printf("  - Binary Search : %10.3f ms (Avg Comparisons: %,d)%n",
                totalBinaryTime / 1e6, totalBinaryComp / sample);
        System.out.printf("  - Overall Speedup: %.1fx faster%n%n", (double) totalLinearTime / totalBinaryTime);

        System.out.println("Theoretical Explanation:");
        System.out.println("  - Linear Search compares elements sequentially: Best=1, Average=n/2 (50,000), Worst=n (100,000).");
        System.out.println("  - Binary Search halves interval at every step: Best=1, Worst=ceil(log2(100,000)) = 17 comparisons.");
        System.out.println("  - In banking audits, 17 comparisons ensure deterministic sub-microsecond SLA regardless of table size.\n");
    }

    private static void testScenario(String label, Transaction[] arr, long targetId) {
        long linTime = 0, binTime = 0;
        int linComp = 0, binComp = 0;
        int runs = 30;

        for (int i = 0; i < runs; i++) {
            SearchMetrics lin = linearSearch(arr, targetId);
            SearchMetrics bin = binarySearch(arr, targetId);
            linTime += lin.durationNanos;
            binTime += bin.durationNanos;
            linComp = lin.comparisons;
            binComp = bin.comparisons;
        }

        long avgLin = Math.max(1, linTime / runs);
        long avgBin = Math.max(1, binTime / runs);
        double speedup = (double) avgLin / avgBin;

        System.out.printf("| %-39s | %8d  | %7d  | %8d  | %7d  | %8.1fx  |%n",
                label, avgLin, linComp, avgBin, binComp, speedup);
    }
}
