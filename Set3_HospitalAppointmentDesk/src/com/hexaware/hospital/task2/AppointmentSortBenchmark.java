package com.hexaware.hospital.task2;

import com.hexaware.hospital.model.Appointment;

import java.time.LocalTime;
import java.util.List;

/**
 * Task 2: Multi-Key Appointment Sorting (Urgency Level then Arrival Time).
 * Compares Selection Sort and Quick Sort on running time and swap counts.
 * Includes a typed paper-trace of the first 3 passes of Selection Sort.
 */
public class AppointmentSortBenchmark {

    public static class SortMetrics {
        public long swaps;
        public long comparisons;
        public long durationMs;

        public SortMetrics(long swaps, long comparisons, long durationMs) {
            this.swaps = swaps;
            this.comparisons = comparisons;
            this.durationMs = durationMs;
        }
    }

    /**
     * Selection Sort:
     * Sorts by urgency level ascending, then by arrival time ascending.
     * Minimizes writes: Exactly at most n - 1 swaps total!
     */
    public static SortMetrics selectionSort(Appointment[] arr) {
        long start = System.currentTimeMillis();
        long comparisons = 0;
        long swaps = 0;
        int n = arr.length;

        for (int i = 0; i < n - 1; i++) {
            int minIdx = i;
            for (int j = i + 1; j < n; j++) {
                comparisons++;
                if (arr[j].compareTo(arr[minIdx]) < 0) {
                    minIdx = j;
                }
            }
            if (minIdx != i) {
                Appointment temp = arr[i];
                arr[i] = arr[minIdx];
                arr[minIdx] = temp;
                swaps++;
            }
        }
        long duration = System.currentTimeMillis() - start;
        return new SortMetrics(swaps, comparisons, duration);
    }

    /**
     * Quick Sort:
     * Fast divide-and-conquer O(n log n) sorting.
     */
    private static long qsSwaps = 0;
    private static long qsComparisons = 0;

    public static SortMetrics quickSort(Appointment[] arr) {
        long start = System.currentTimeMillis();
        qsSwaps = 0;
        qsComparisons = 0;
        quickSortHelper(arr, 0, arr.length - 1);
        long duration = System.currentTimeMillis() - start;
        return new SortMetrics(qsSwaps, qsComparisons, duration);
    }

    private static void quickSortHelper(Appointment[] arr, int low, int high) {
        if (low < high) {
            int p = partition(arr, low, high);
            quickSortHelper(arr, low, p - 1);
            quickSortHelper(arr, p + 1, high);
        }
    }

    private static int partition(Appointment[] arr, int low, int high) {
        Appointment pivot = arr[high];
        int i = low - 1;

        for (int j = low; j < high; j++) {
            qsComparisons++;
            if (arr[j].compareTo(pivot) <= 0) {
                i++;
                swap(arr, i, j);
            }
        }
        swap(arr, i + 1, high);
        return i + 1;
    }

    private static void swap(Appointment[] arr, int i, int j) {
        if (i != j) {
            Appointment temp = arr[i];
            arr[i] = arr[j];
            arr[j] = temp;
            qsSwaps++;
        }
    }

    /**
     * Typed Paper-Trace of First 3 Passes of Selection Sort.
     */
    public static void printPaperTrace() {
        System.out.println("--------------------------------------------------------------------------------");
        System.out.println("  TYPED PAPER-TRACE: FIRST 3 PASSES OF SELECTION SORT");
        System.out.println("  Sorting Criteria: (1) Urgency (L1 > L2 > L3 > L4), (2) Arrival Time");
        System.out.println("--------------------------------------------------------------------------------");

        Appointment[] sample = {
                new Appointment(101, 1, "Alice", 3, LocalTime.of(9, 30), "09:30", 30), // Standard L3, 09:30
                new Appointment(102, 2, "Bob",   1, LocalTime.of(10, 0), "10:00", 30), // Critical L1, 10:00
                new Appointment(103, 3, "Carol", 2, LocalTime.of(9, 15), "09:15", 30), // Urgent L2, 09:15
                new Appointment(104, 4, "Dave",  1, LocalTime.of(9, 0),  "09:00", 30), // Critical L1, 09:00
                new Appointment(105, 5, "Eve",   4, LocalTime.of(8, 45), "08:45", 30), // Routine L4, 08:45
                new Appointment(106, 6, "Frank", 2, LocalTime.of(8, 30), "08:30", 30)  // Urgent L2, 08:30
        };

        System.out.println("Initial Appointment List:");
        for (int i = 0; i < sample.length; i++) {
            System.out.printf("  Index %d: %s%n", i, sample[i]);
        }
        System.out.println();

        for (int pass = 1; pass <= 3; pass++) {
            int i = pass - 1;
            int minIdx = i;
            System.out.printf("=== PASS %d (Finding smallest from Index %d to %d) ===%n", pass, i, sample.length - 1);

            for (int j = i + 1; j < sample.length; j++) {
                System.out.printf("  Compare arr[%d] (%s, %s) with current minimum arr[%d] (%s, %s) -> ",
                        j, sample[j].getUrgencyLabel(), sample[j].getArrivalTime(),
                        minIdx, sample[minIdx].getUrgencyLabel(), sample[minIdx].getArrivalTime());
                if (sample[j].compareTo(sample[minIdx]) < 0) {
                    minIdx = j;
                    System.out.printf("NEW MINIMUM at Index %d!%n", minIdx);
                } else {
                    System.out.println("no change");
                }
            }

            if (minIdx != i) {
                System.out.printf("  >> SWAP arr[%d] (%s) with arr[%d] (%s)%n", i, sample[i].getPatientName(), minIdx, sample[minIdx].getPatientName());
                Appointment t = sample[i];
                sample[i] = sample[minIdx];
                sample[minIdx] = t;
            } else {
                System.out.printf("  >> NO SWAP (arr[%d] is already the minimum)%n", i);
            }

            System.out.printf("  Array after Pass %d: [ ", pass);
            for (int k = 0; k < sample.length; k++) {
                if (k <= i) {
                    System.out.printf("*%s* ", sample[k].getPatientName());
                } else {
                    System.out.printf("%s ", sample[k].getPatientName());
                }
            }
            System.out.printf("]  (*indicates settled position)%n%n");
        }
    }

    public static void runBenchmark(List<Appointment> appointments) {
        System.out.println("================================================================================");
        System.out.println("   TASK 2: APPOINTMENT SORTING BENCHMARK - SELECTION SORT VS QUICK SORT");
        System.out.println("================================================================================");

        printPaperTrace();

        int n = Math.min(3000, appointments.size());
        System.out.printf("Benchmarking on %,d appointments:%n", n);

        Appointment[] arrSelection = appointments.subList(0, n).toArray(new Appointment[0]);
        Appointment[] arrQuick = arrSelection.clone();

        SortMetrics smSelection = selectionSort(arrSelection);
        SortMetrics smQuick = quickSort(arrQuick);

        System.out.println("+----------------------+-------------------+-----------------------+------------------+");
        System.out.println("| Algorithm            | Running Time (ms) | Total Swaps           | Comparisons      |");
        System.out.println("+----------------------+-------------------+-----------------------+------------------+");
        System.out.printf("| Selection Sort       | %14d ms | %,21d | %,16d |%n",
                smSelection.durationMs, smSelection.swaps, smSelection.comparisons);
        System.out.printf("| Quick Sort           | %14d ms | %,21d | %,16d |%n",
                smQuick.durationMs, smQuick.swaps, smQuick.comparisons);
        System.out.println("+----------------------+-------------------+-----------------------+------------------+");

        System.out.printf("%nComparative Takeaways:%n");
        System.out.printf("  1. Swap Count: Selection Sort performed %,d swaps (at most n-1 = %,d).%n",
                smSelection.swaps, n - 1);
        System.out.printf("     Quick Sort performed %,d swaps (%dx more memory writes).%n",
                smQuick.swaps, smQuick.swaps / Math.max(1, smSelection.swaps));
        System.out.printf("  2. Running Time: Quick Sort was %.1fx faster due to O(n log n) comparison efficiency.%n",
                (double) Math.max(1, smSelection.durationMs) / Math.max(1, smQuick.durationMs));
        System.out.println("  3. Trade-off: If memory writes are expensive (e.g. Flash/EEPROM devices), Selection Sort");
        System.out.println("     is optimal; for high-throughput roster sorting, Quick Sort is vastly superior.\n");
    }
}
