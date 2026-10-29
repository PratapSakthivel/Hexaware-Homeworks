package com.hexaware.retail.task1;

import com.hexaware.retail.model.Order;

import java.util.*;

/**
 * Task 1: Search Benchmarking
 * Implements Linear Search and Binary Search on 50,000 order records by Order ID,
 * benchmarks execution time & comparison counts, and explains theoretical vs empirical differences.
 */
public class SearchBenchmark {

    public static class SearchResult {
        public final Order order;
        public final int comparisons;
        public final long elapsedNanos;

        public SearchResult(Order order, int comparisons, long elapsedNanos) {
            this.order = order;
            this.comparisons = comparisons;
            this.elapsedNanos = elapsedNanos;
        }
    }

    /**
     * Linear Search: Sequentially iterates through the order collection.
     * Time Complexity: Best O(1), Average O(n), Worst O(n).
     * Space Complexity: O(1).
     */
    public static SearchResult linearSearch(List<Order> list, int targetId) {
        long startTime = System.nanoTime();
        int comparisons = 0;
        Order found = null;
        for (Order order : list) {
            comparisons++;
            if (order.getOrderId() == targetId) {
                found = order;
                break;
            }
        }
        long duration = System.nanoTime() - startTime;
        return new SearchResult(found, comparisons, duration);
    }

    /**
     * Binary Search: Repeatedly halves search space on an array pre-sorted by Order ID.
     * Time Complexity: Best O(1), Average O(log n), Worst O(log n).
     * Space Complexity: O(1).
     */
    public static SearchResult binarySearch(Order[] sortedArr, int targetId) {
        long startTime = System.nanoTime();
        int comparisons = 0;
        int low = 0;
        int high = sortedArr.length - 1;
        Order found = null;

        while (low <= high) {
            comparisons++;
            int mid = low + (high - low) / 2;
            int midId = sortedArr[mid].getOrderId();

            if (midId == targetId) {
                found = sortedArr[mid];
                break;
            } else if (midId < targetId) {
                low = mid + 1;
            } else {
                high = mid - 1;
            }
        }
        long duration = System.nanoTime() - startTime;
        return new SearchResult(found, comparisons, duration);
    }

    public static void runBenchmark(List<Order> orders) {
        System.out.println("================================================================================");
        System.out.println("   TASK 1: RETRIEVAL BENCHMARK - LINEAR SEARCH VS BINARY SEARCH (50,000 RECORDS)");
        System.out.println("================================================================================");
        int n = orders.size();
        System.out.printf("Total orders loaded: %,d records%n%n", n);

        // Prepare sorted array for binary search
        Order[] sortedOrders = orders.toArray(new Order[0]);
        Arrays.sort(sortedOrders, Comparator.comparingInt(Order::getOrderId));

        // Warm up the JVM JIT compiler to ensure fair timing
        for (int i = 0; i < 5000; i++) {
            linearSearch(orders, 100_001);
            binarySearch(sortedOrders, 100_001);
        }

        // Test scenarios:
        // 1. First record (Best Case for Linear)
        // 2. Middle record
        // 3. Last record (Worst Case for Linear Found)
        // 4. Missing record (Absolute Worst Case)
        int idFirst = orders.get(0).getOrderId();
        int idMid = orders.get(n / 2).getOrderId();
        int idLast = orders.get(n - 1).getOrderId();
        int idMissing = 999_999; // Not present

        int[] testCases = {idFirst, idMid, idLast, idMissing};
        String[] descriptions = {
                "First Element (Linear Best Case)",
                "Middle Element (Linear Average Case)",
                "Last Element (Linear Worst Case Found)",
                "Non-existent Element (Worst Case Miss)"
        };

        System.out.println("+-----------------------------------------+----------------------+----------------------+------------+");
        System.out.println("| Test Scenario                           | Linear Search        | Binary Search        | Speedup    |");
        System.out.println("|                                         | Time (ns) | Comp.    | Time (ns) | Comp.    | Factor     |");
        System.out.println("+-----------------------------------------+-----------+----------+-----------+----------+------------+");

        for (int i = 0; i < testCases.length; i++) {
            int target = testCases[i];
            // Run multiple iterations to smooth out OS scheduling anomalies
            long linearTotalTime = 0;
            long binaryTotalTime = 0;
            int linearComp = 0;
            int binaryComp = 0;
            int runs = 50;

            for (int r = 0; r < runs; r++) {
                SearchResult rLin = linearSearch(orders, target);
                SearchResult rBin = binarySearch(sortedOrders, target);
                linearTotalTime += rLin.elapsedNanos;
                binaryTotalTime += rBin.elapsedNanos;
                linearComp = rLin.comparisons;
                binaryComp = rBin.comparisons;
            }

            long avgLin = Math.max(1, linearTotalTime / runs);
            long avgBin = Math.max(1, binaryTotalTime / runs);
            double speedup = (double) avgLin / avgBin;

            System.out.printf("| %-39s | %8d  | %7d  | %8d  | %7d  | %8.1fx  |%n",
                    descriptions[i], avgLin, linearComp, avgBin, binaryComp, speedup);
        }
        System.out.println("+-----------------------------------------+-----------+----------+-----------+----------+------------+");

        // Comprehensive batch test: 1,000 random queries
        System.out.println("\n--- Batch Test: 1,000 Random Order ID Queries ---");
        Random rnd = new Random(12345);
        long batchLinearTime = 0;
        long batchBinaryTime = 0;
        int totalLinearComp = 0;
        int totalBinaryComp = 0;
        int batchSize = 1000;

        for (int i = 0; i < batchSize; i++) {
            int randomTarget = orders.get(rnd.nextInt(n)).getOrderId();
            SearchResult linRes = linearSearch(orders, randomTarget);
            SearchResult binRes = binarySearch(sortedOrders, randomTarget);
            batchLinearTime += linRes.elapsedNanos;
            batchBinaryTime += binRes.elapsedNanos;
            totalLinearComp += linRes.comparisons;
            totalBinaryComp += binRes.comparisons;
        }

        System.out.printf("Total Time for %,d queries:%n", batchSize);
        System.out.printf("  - Linear Search : %10.3f ms (Avg Comparisons: %,d per query)%n",
                batchLinearTime / 1_000_000.0, totalLinearComp / batchSize);
        System.out.printf("  - Binary Search : %10.3f ms (Avg Comparisons: %,d per query)%n",
                batchBinaryTime / 1_000_000.0, totalBinaryComp / batchSize);
        System.out.printf("  - Overall Speedup: %.1fx faster%n%n", (double) batchLinearTime / batchBinaryTime);

        // Theoretical explanation
        System.out.println("--- Analysis & Explanation of Observed Differences ---");
        System.out.println("1. Complexity Difference: Linear Search has O(n) complexity. With n = 50,000 records,");
        System.out.println("   it requires on average n/2 = 25,000 comparisons and 50,000 comparisons in the worst case.");
        System.out.println("2. Logarithmic Scalability: Binary Search has O(log2 n) complexity. For n = 50,000,");
        System.out.println("   ceil(log2(50,000)) = 16 comparisons maximum. It eliminates half of the remaining space");
        System.out.println("   at every step, resulting in a dramatic orders-of-magnitude performance improvement.");
        System.out.println("3. Hardware & Memory: Sequential memory traversal in linear search experiences cache line");
        System.out.println("   benefits but is completely overshadowed by 25,000 pointer dereferences versus only ~15 for binary search.");
        System.out.println("4. Precondition: Binary search requires sorted data (O(n log n) one-time cost). In a high-read");
        System.out.println("   support desk scenario where orders are queried tens of thousands of times, pre-sorting or indexing");
        System.out.println("   by Order ID pays for itself almost immediately.\n");
    }
}
