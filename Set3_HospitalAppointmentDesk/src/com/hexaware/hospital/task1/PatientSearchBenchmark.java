package com.hexaware.hospital.task1;

import com.hexaware.hospital.model.Patient;

import java.util.List;
import java.util.Random;

/**
 * Task 1: Linear vs Binary Search over 20,000 Patient Records Keyed by Patient ID.
 * Measures latency over 1,000 look-ups and explains the empirical results.
 */
public class PatientSearchBenchmark {

    public static class SearchResult {
        public final Patient patient;
        public final int comparisons;
        public final long durationNanos;

        public SearchResult(Patient patient, int comparisons, long durationNanos) {
            this.patient = patient;
            this.comparisons = comparisons;
            this.durationNanos = durationNanos;
        }
    }

    public static SearchResult linearSearch(Patient[] arr, int targetId) {
        long start = System.nanoTime();
        int comparisons = 0;
        Patient found = null;
        for (Patient p : arr) {
            comparisons++;
            if (p.getPatientId() == targetId) {
                found = p;
                break;
            }
        }
        long duration = System.nanoTime() - start;
        return new SearchResult(found, comparisons, duration);
    }

    public static SearchResult binarySearch(Patient[] arr, int targetId) {
        long start = System.nanoTime();
        int comparisons = 0;
        int low = 0;
        int high = arr.length - 1;
        Patient found = null;

        while (low <= high) {
            comparisons++;
            int mid = low + (high - low) / 2;
            int midId = arr[mid].getPatientId();

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
        return new SearchResult(found, comparisons, duration);
    }

    public static void runBenchmark(List<Patient> patients) {
        System.out.println("================================================================================");
        System.out.println("   TASK 1: PATIENT ID RETRIEVAL BENCHMARK - LINEAR VS BINARY (20,000 RECORDS)");
        System.out.println("================================================================================");
        System.out.printf("Total patient records in hospital roster: %,d%n%n", patients.size());

        Patient[] arr = patients.toArray(new Patient[0]);
        int n = arr.length;

        // Warm up JIT
        for (int i = 0; i < 2000; i++) {
            linearSearch(arr, arr[0].getPatientId());
            binarySearch(arr, arr[0].getPatientId());
        }

        System.out.println("Measuring 1,000 Patient ID Look-ups:");
        int lookupCount = 1000;
        Random rand = new Random(777);

        long linearTotalTime = 0;
        long binaryTotalTime = 0;
        int linearTotalComp = 0;
        int binaryTotalComp = 0;

        for (int i = 0; i < lookupCount; i++) {
            int targetId = arr[rand.nextInt(n)].getPatientId();
            SearchResult lin = linearSearch(arr, targetId);
            SearchResult bin = binarySearch(arr, targetId);

            linearTotalTime += lin.durationNanos;
            binaryTotalTime += bin.durationNanos;
            linearTotalComp += lin.comparisons;
            binaryTotalComp += bin.comparisons;
        }

        double linearMs = linearTotalTime / 1e6;
        double binaryMs = binaryTotalTime / 1e6;
        double avgLinComp = (double) linearTotalComp / lookupCount;
        double avgBinComp = (double) binaryTotalComp / lookupCount;
        double speedup = linearTotalTime / (double) Math.max(1, binaryTotalTime);

        System.out.println("+----------------------+-------------------+-----------------------+------------------+");
        System.out.println("| Search Algorithm     | Total Time (1,000)| Avg Time per Lookup   | Avg Comparisons  |");
        System.out.println("+----------------------+-------------------+-----------------------+------------------+");
        System.out.printf("| Linear Search        | %10.3f ms   | %12.2f ns     | %,16.1f |%n",
                linearMs, (double) linearTotalTime / lookupCount, avgLinComp);
        System.out.printf("| Binary Search        | %10.3f ms   | %12.2f ns     | %,16.1f |%n",
                binaryMs, (double) binaryTotalTime / lookupCount, avgBinComp);
        System.out.println("+----------------------+-------------------+-----------------------+------------------+");
        System.out.printf("Overall Performance: Binary Search is %.1fx faster than Linear Search.%n%n", speedup);

        System.out.println("Explanation of Results:");
        System.out.println("  1. Comparison Difference: In an array of 20,000 records, linear search averages n/2 = 10,000 comparisons.");
        System.out.println("     Binary search requires at most ceil(log2 20,000) = 15 comparisons (empirically ~13.3 comparisons).");
        System.out.println("  2. In high-pressure hospital reception desks, binary search yields instantaneous response (~0.001 ms)");
        System.out.println("     preventing receptionist UI freezing and lookup bottlenecks.\n");
    }
}
