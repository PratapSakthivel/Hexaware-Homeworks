package com.hexaware.banking.task5;

import com.hexaware.banking.model.Transaction;

import java.util.List;

/**
 * Task 5: Extreme Transaction Amount Finder (Min/Max).
 * Compares Divide-and-Conquer vs Brute-Force Scan on 100,000 daily transactions.
 */
public class ExtremeAmountFinder {

    public static class MinMaxResult {
        public double min;
        public double max;
        public long comparisons;
        public long durationNanos;

        public MinMaxResult(double min, double max, long comparisons, long durationNanos) {
            this.min = min;
            this.max = max;
            this.comparisons = comparisons;
            this.durationNanos = durationNanos;
        }

        @Override
        public String toString() {
            return String.format("Min: $%.2f | Max: $%.2f | Comparisons: %,d | Time: %.3f ms",
                    min, max, comparisons, durationNanos / 1e6);
        }
    }

    private static class Pair {
        double min;
        double max;

        Pair(double min, double max) {
            this.min = min;
            this.max = max;
        }
    }

    /**
     * Brute-Force Scan:
     * Compares every element against current min and max.
     * Number of comparisons: up to 2*(n - 1).
     */
    public static MinMaxResult findMinMaxBruteForce(double[] amounts) {
        long start = System.nanoTime();
        long comparisons = 0;
        int n = amounts.length;
        if (n == 0) return new MinMaxResult(0, 0, 0, 0);

        double min = amounts[0];
        double max = amounts[0];

        for (int i = 1; i < n; i++) {
            comparisons++;
            if (amounts[i] < min) {
                min = amounts[i];
            } else {
                comparisons++;
                if (amounts[i] > max) {
                    max = amounts[i];
                }
            }
        }
        long duration = System.nanoTime() - start;
        return new MinMaxResult(min, max, comparisons, duration);
    }

    /**
     * Divide-and-Conquer Min/Max:
     * Recurrence: T(n) = 2T(n/2) + 2.
     * Total comparisons: exactly 3n/2 - 2 (25% fewer comparisons than brute-force worst case).
     */
    private static long dcComparisons = 0;

    public static MinMaxResult findMinMaxDivideAndConquer(double[] amounts) {
        long start = System.nanoTime();
        dcComparisons = 0;
        Pair p = divideAndConquerHelper(amounts, 0, amounts.length - 1);
        long duration = System.nanoTime() - start;
        return new MinMaxResult(p.min, p.max, dcComparisons, duration);
    }

    private static Pair divideAndConquerHelper(double[] arr, int low, int high) {
        // Base Case 1: 1 element
        if (low == high) {
            return new Pair(arr[low], arr[low]);
        }

        // Base Case 2: 2 elements
        if (high == low + 1) {
            dcComparisons++;
            if (arr[low] < arr[high]) {
                return new Pair(arr[low], arr[high]);
            } else {
                return new Pair(arr[high], arr[low]);
            }
        }

        // Divide
        int mid = low + (high - low) / 2;
        Pair left = divideAndConquerHelper(arr, low, mid);
        Pair right = divideAndConquerHelper(arr, mid + 1, high);

        // Conquer / Combine (2 comparisons)
        dcComparisons += 2;
        double min = Math.min(left.min, right.min);
        double max = Math.max(left.max, right.max);

        return new Pair(min, max);
    }

    public static void runDemo(List<Transaction> transactions) {
        System.out.println("================================================================================");
        System.out.println("   TASK 5: FINDING MIN/MAX AMOUNTS - DIVIDE-AND-CONQUER VS BRUTE FORCE");
        System.out.println("================================================================================");
        System.out.printf("Scanning %,d transactions in daily ledger...%n%n", transactions.size());

        double[] amounts = new double[transactions.size()];
        for (int i = 0; i < transactions.size(); i++) {
            amounts[i] = transactions.get(i).getAmount();
        }

        // Warm up
        for (int i = 0; i < 50; i++) {
            findMinMaxBruteForce(amounts);
            findMinMaxDivideAndConquer(amounts);
        }

        MinMaxResult bfResult = findMinMaxBruteForce(amounts);
        MinMaxResult dcResult = findMinMaxDivideAndConquer(amounts);

        System.out.println("+----------------------+---------------------+-------------------+---------------------+");
        System.out.println("| Algorithm            | Lowest Amount (Min) | Highest (Max)     | Comparisons Count   |");
        System.out.println("+----------------------+---------------------+-------------------+---------------------+");
        System.out.printf("| Brute-Force Scan     | $%-18.2f | $%-16.2f | %,19d |%n",
                bfResult.min, bfResult.max, bfResult.comparisons);
        System.out.printf("| Divide-and-Conquer   | $%-18.2f | $%-16.2f | %,19d |%n",
                dcResult.min, dcResult.max, dcResult.comparisons);
        System.out.println("+----------------------+---------------------+-------------------+---------------------+");

        long comparisonSavings = bfResult.comparisons - dcResult.comparisons;
        double percentageSaved = ((double) comparisonSavings / bfResult.comparisons) * 100.0;

        System.out.printf("Mathematical Comparison Proof:%n");
        System.out.printf("  - Brute Force Comparisons : %,d comparisons (worst case 2*(n-1) = %,d)%n",
                bfResult.comparisons, 2 * (amounts.length - 1));
        System.out.printf("  - Divide & Conquer        : %,d comparisons (exact formula 3n/2 - 2 = %,d)%n",
                dcResult.comparisons, (long)(1.5 * amounts.length - 2));
        System.out.printf("  - Comparison Reduction    : %,d fewer comparisons (%.1f%% reduction)%n%n",
                comparisonSavings, percentageSaved);

        System.out.println("Takeaways for Banking Systems:");
        System.out.println("  1. In massive batch ledgers, Divide-and-Conquer guarantees exactly 1.5n comparisons");
        System.out.println("     regardless of data distribution, whereas brute-force fluctuates up to 2n.");
        System.out.println("  2. Divide-and-Conquer enables effortless parallelization across multi-core CPUs via ForkJoinPool.\n");
    }
}
