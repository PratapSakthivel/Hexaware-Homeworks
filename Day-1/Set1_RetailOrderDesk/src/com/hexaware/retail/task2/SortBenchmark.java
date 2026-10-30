package com.hexaware.retail.task2;

import com.hexaware.retail.model.Order;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

/**
 * Task 2: Sorting Algorithm Benchmarking & Tracing
 * Implements:
 * 1. O(n^2) Sort: Bubble Sort (Descending by amount)
 * 2. O(n log n) Sort: Merge Sort (Descending by amount)
 * 3. Built-in Sort: Arrays.sort (TimSort for objects)
 * Includes a step-by-step paper-trace simulation of the first three passes,
 * and benchmarks all three on 10,000 records.
 */
public class SortBenchmark {

    /**
     * O(n^2) Sorting Algorithm: Bubble Sort (Descending order by amount)
     * Compares adjacent pairs and swaps them if the left element is smaller than the right.
     */
    public static void bubbleSort(Order[] arr) {
        int n = arr.length;
        for (int i = 0; i < n - 1; i++) {
            boolean swapped = false;
            for (int j = 0; j < n - 1 - i; j++) {
                // Descending: if arr[j] < arr[j+1], swap
                if (arr[j].getAmount() < arr[j + 1].getAmount()) {
                    Order temp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = temp;
                    swapped = true;
                }
            }
            if (!swapped) break; // Optimization: early stop if already sorted
        }
    }

    /**
     * O(n log n) Sorting Algorithm: Merge Sort (Descending order by amount)
     * Divide-and-conquer approach: divides array into halves, recursively sorts, and merges.
     */
    public static void mergeSort(Order[] arr, int left, int right) {
        if (left < right) {
            int mid = left + (right - left) / 2;
            mergeSort(arr, left, mid);
            mergeSort(arr, mid + 1, right);
            merge(arr, left, mid, right);
        }
    }

    private static void merge(Order[] arr, int left, int mid, int right) {
        int n1 = mid - left + 1;
        int n2 = right - mid;

        Order[] L = new Order[n1];
        Order[] R = new Order[n2];

        System.arraycopy(arr, left, L, 0, n1);
        System.arraycopy(arr, mid + 1, R, 0, n2);

        int i = 0, j = 0, k = left;
        while (i < n1 && j < n2) {
            // Descending order: take larger amount first
            if (L[i].getAmount() >= R[j].getAmount()) {
                arr[k++] = L[i++];
            } else {
                arr[k++] = R[j++];
            }
        }

        while (i < n1) {
            arr[k++] = L[i++];
        }
        while (j < n2) {
            arr[k++] = R[j++];
        }
    }

    /**
     * Traces the first three passes of Bubble Sort on paper / console for verification.
     */
    public static void printFirstThreePassesTrace() {
        System.out.println("--------------------------------------------------------------------------------");
        System.out.println("  TRACE OF FIRST 3 PASSES (Bubble Sort - Descending Order by Order Amount)");
        System.out.println("--------------------------------------------------------------------------------");

        // Sample of 6 representative orders for clear tracing
        double[] sampleAmounts = {150.00, 890.50, 45.00, 520.00, 310.00, 750.00};
        int n = sampleAmounts.length;

        System.out.print("Initial Order Amounts Array: [ ");
        for (double amt : sampleAmounts) System.out.printf("$%.2f ", amt);
        System.out.println("]\nGoal: Rank descending (highest amount to lowest amount)\n");

        double[] arr = sampleAmounts.clone();

        for (int pass = 1; pass <= 3; pass++) {
            System.out.printf("=== PASS %d ===%n", pass);
            int comparisons = 0;
            int swaps = 0;

            for (int j = 0; j < n - pass; j++) {
                comparisons++;
                boolean doSwap = arr[j] < arr[j + 1];
                System.out.printf("  Step %d.%d: Compare arr[%d]=%.2f and arr[%d]=%.2f -> %s%n",
                        pass, j + 1, j, arr[j], j + 1, arr[j + 1],
                        doSwap ? "SWAP (since " + arr[j] + " < " + arr[j + 1] + ")" : "NO SWAP (already in descending order)");
                if (doSwap) {
                    double tmp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = tmp;
                    swaps++;
                }
            }

            System.out.printf("  Summary of Pass %d: Comparisons = %d, Swaps = %d%n", pass, comparisons, swaps);
            System.out.printf("  Array after Pass %d: [ ", pass);
            for (int k = 0; k < arr.length; k++) {
                if (k >= n - pass) {
                    System.out.printf("*%.2f* ", arr[k]); // Element settled at its final position
                } else {
                    System.out.printf("%.2f ", arr[k]);
                }
            }
            System.out.printf("]  (*indicates sorted tail element)%n%n");
        }
        System.out.println("Observation after 3 passes:");
        System.out.println("  - The 3 smallest amounts (45.00, 150.00, 310.00) have settled into their final positions at the tail.");
        System.out.println("  - The unsorted prefix shrinks by 1 after every pass.");
    }

    public static void runBenchmark(List<Order> fullOrders) {
        System.out.println("================================================================================");
        System.out.println("   TASK 2: SORTING BENCHMARK - O(n^2) VS O(n log n) VS BUILT-IN (10,000 RECORDS)");
        System.out.println("================================================================================");

        int sampleSize = 10_000;
        if (fullOrders.size() < sampleSize) {
            sampleSize = fullOrders.size();
        }

        System.out.printf("Extracting first %,d records for sorting comparison...%n%n", sampleSize);

        Order[] original = new Order[sampleSize];
        for (int i = 0; i < sampleSize; i++) {
            original[i] = fullOrders.get(i);
        }

        // 1. First print paper trace of 3 passes
        printFirstThreePassesTrace();

        // 2. Prepare 3 identical copies for fair benchmarking
        Order[] arrBubble = original.clone();
        Order[] arrMerge = original.clone();
        Order[] arrBuiltIn = original.clone();

        System.out.println("--------------------------------------------------------------------------------");
        System.out.printf("Benchmarking 3 Sorting Algorithms on %,d records:%n", sampleSize);
        System.out.println("--------------------------------------------------------------------------------");

        // Benchmark Bubble Sort
        System.out.print("Running Bubble Sort [O(n^2)] ... ");
        long t0 = System.currentTimeMillis();
        bubbleSort(arrBubble);
        long bubbleTimeMs = System.currentTimeMillis() - t0;
        System.out.printf("Done in %,d ms%n", bubbleTimeMs);

        // Benchmark Merge Sort
        System.out.print("Running Merge Sort [O(n log n)] ... ");
        long t1 = System.currentTimeMillis();
        mergeSort(arrMerge, 0, arrMerge.length - 1);
        long mergeTimeMs = System.currentTimeMillis() - t1;
        System.out.printf("Done in %,d ms%n", mergeTimeMs);

        // Benchmark Built-in Sort (TimSort)
        System.out.print("Running Built-in Arrays.sort() [TimSort / O(n log n)] ... ");
        long t2 = System.currentTimeMillis();
        // Since Order implements Comparable (descending by amount), natural order sorts descending
        Arrays.sort(arrBuiltIn);
        long builtInTimeMs = System.currentTimeMillis() - t2;
        System.out.printf("Done in %,d ms%n%n", builtInTimeMs);

        // Verify all 3 produced the same sorted ranking
        boolean identical = true;
        for (int i = 0; i < sampleSize; i++) {
            if (Double.compare(arrBubble[i].getAmount(), arrMerge[i].getAmount()) != 0 ||
                Double.compare(arrMerge[i].getAmount(), arrBuiltIn[i].getAmount()) != 0) {
                identical = false;
                break;
            }
        }

        System.out.println("+--------------------------------+--------------------+-------------------+---------------+");
        System.out.println("| Algorithm                      | Time Complexity    | Execution Time    | Speedup vs    |");
        System.out.println("|                                | (Best / Avg / Worst| (10,000 records)  | Bubble Sort   |");
        System.out.println("+--------------------------------+--------------------+-------------------+---------------+");
        System.out.printf("| Bubble Sort                    | O(n) / O(n^2)/O(n^2)| %8d ms        |        1.0x   |%n", bubbleTimeMs);
        System.out.printf("| Merge Sort (Custom)            | O(n log n) always  | %8d ms        | %10.1fx   |%n",
                mergeTimeMs, bubbleTimeMs / Math.max(1.0, mergeTimeMs));
        System.out.printf("| Built-in Arrays.sort (TimSort) | O(n) / O(n log n)  | %8d ms        | %10.1fx   |%n",
                builtInTimeMs, bubbleTimeMs / Math.max(1.0, builtInTimeMs));
        System.out.println("+--------------------------------+--------------------+-------------------+---------------+");
        System.out.printf("Verification: All algorithms produced identical sorted order? -> %s%n",
                identical ? "YES (VERIFIED)" : "NO (MISMATCH)");

        System.out.println("\nTop 5 Ranked Orders by Amount (Warehouse Dispatch Priority):");
        for (int i = 0; i < 5; i++) {
            System.out.printf("  Rank %d: %s%n", i + 1, arrMerge[i]);
        }
        System.out.println();
    }
}
