package com.hexaware.hospital.task5;

import java.time.LocalTime;
import java.util.*;

/**
 * Task 5: Doctor Shift Scheduling (Overlapping Slots with Different Durations).
 * Compares Greedy vs Dynamic Programming (Weighted Interval Scheduling).
 * Demonstrates a concrete scenario where Greedy yields sub-optimal physician utilization,
 * and solves it optimally using Dynamic Programming.
 */
public class DoctorShiftScheduler {

    public static class ShiftSlot implements Comparable<ShiftSlot> {
        public final int id;
        public final String patientName;
        public final LocalTime start;
        public final LocalTime end;
        public final int durationMinutes; // or clinical consultation value
        public final int weight; // Value or clinical priority

        public ShiftSlot(int id, String patientName, LocalTime start, LocalTime end, int weight) {
            this.id = id;
            this.patientName = patientName;
            this.start = start;
            this.end = end;
            this.durationMinutes = (int) java.time.Duration.between(start, end).toMinutes();
            this.weight = weight;
        }

        @Override
        public int compareTo(ShiftSlot o) {
            return this.end.compareTo(o.end); // Sort by finish time
        }

        @Override
        public String toString() {
            return String.format("[%s: %s-%s (%d min, Weight: %d)]",
                    patientName, start, end, durationMinutes, weight);
        }
    }

    public static class ScheduleResult {
        public final List<ShiftSlot> selected;
        public final int totalWeight;
        public final String algorithm;

        public ScheduleResult(List<ShiftSlot> selected, int totalWeight, String algorithm) {
            this.selected = selected;
            this.totalWeight = totalWeight;
            this.algorithm = algorithm;
        }
    }

    /**
     * Greedy Approach (Earliest Finish Time First).
     * Optimal only for unweighted unit-duration intervals; sub-optimal when slots carry different durations/weights.
     */
    public static ScheduleResult scheduleGreedy(List<ShiftSlot> slots) {
        List<ShiftSlot> sorted = new ArrayList<>(slots);
        Collections.sort(sorted); // Sort by end time

        List<ShiftSlot> selected = new ArrayList<>();
        LocalTime lastEnd = LocalTime.MIN;
        int totalWeight = 0;

        for (ShiftSlot slot : sorted) {
            if (!slot.start.isBefore(lastEnd)) {
                selected.add(slot);
                lastEnd = slot.end;
                totalWeight += slot.weight;
            }
        }
        return new ScheduleResult(selected, totalWeight, "Greedy (Earliest Finish Time)");
    }

    /**
     * Dynamic Programming Approach (Weighted Interval Scheduling):
     * DP[i] = max(DP[i - 1], weight(i) + DP[p(i)])
     * Time Complexity: O(n log n) sorting + binary search.
     * Space Complexity: O(n) DP table and parent pointers.
     */
    public static ScheduleResult scheduleDynamicProgramming(List<ShiftSlot> slots) {
        List<ShiftSlot> sorted = new ArrayList<>(slots);
        Collections.sort(sorted); // 1-indexed DP below
        int n = sorted.size();

        int[] dp = new int[n + 1];
        int[] parent = new int[n + 1];

        // Find p[i]: latest compatible interval preceding interval i
        int[] p = new int[n + 1];
        for (int i = 1; i <= n; i++) {
            p[i] = findLatestCompatible(sorted, i);
        }

        dp[0] = 0;
        for (int i = 1; i <= n; i++) {
            int includeWeight = sorted.get(i - 1).weight + dp[p[i]];
            int excludeWeight = dp[i - 1];

            if (includeWeight > excludeWeight) {
                dp[i] = includeWeight;
                parent[i] = 1; // included
            } else {
                dp[i] = excludeWeight;
                parent[i] = 0; // excluded
            }
        }

        // Backtrack to find selected appointments
        List<ShiftSlot> selected = new ArrayList<>();
        int curr = n;
        while (curr > 0) {
            if (parent[curr] == 1) {
                selected.add(sorted.get(curr - 1));
                curr = p[curr];
            } else {
                curr--;
            }
        }
        Collections.reverse(selected);

        return new ScheduleResult(selected, dp[n], "Dynamic Programming (Optimal)");
    }

    private static int findLatestCompatible(List<ShiftSlot> sorted, int index) {
        LocalTime targetStart = sorted.get(index - 1).start;
        int low = 0, high = index - 2;
        int best = 0;

        while (low <= high) {
            int mid = low + (high - low) / 2;
            if (!sorted.get(mid).end.isAfter(targetStart)) {
                best = mid + 1; // 1-based index
                low = mid + 1;
            } else {
                high = mid - 1;
            }
        }
        return best;
    }

    public static void runDemo() {
        System.out.println("================================================================================");
        System.out.println("   TASK 5: DOCTOR SHIFT SCHEDULER - DYNAMIC PROGRAMMING VS GREEDY");
        System.out.println("================================================================================");

        // Demonstrating a real hospital shift scenario where Greedy FAILS:
        // A doctor has an 8-hour shift (08:00 to 16:00).
        // Overlapping requests arrive with different durations and critical patient weights:
        // 1. Apt 1 (Minor Consultation): 08:30 - 09:30 (Weight: 30) -> Finishes earliest!
        // 2. Apt 2 (Major Emergency Surgery): 09:00 - 13:00 (Weight: 180) -> Overlaps with 1 and 3!
        // 3. Apt 3 (Routine Checkup): 12:30 - 13:30 (Weight: 30)
        // 4. Apt 4 (Complex Cardiology Procedure): 13:30 - 16:00 (Weight: 140)
        List<ShiftSlot> slots = Arrays.asList(
                new ShiftSlot(1, "Minor Clinic A",   LocalTime.of(8, 30), LocalTime.of(9, 30), 30),
                new ShiftSlot(2, "Major Surgery B",  LocalTime.of(9, 0),  LocalTime.of(13, 0), 180),
                new ShiftSlot(3, "Routine Followup", LocalTime.of(12, 30), LocalTime.of(13, 30), 30),
                new ShiftSlot(4, "Cardiology Proc",  LocalTime.of(13, 30), LocalTime.of(16, 0), 140)
        );

        System.out.println("Requested Overlapping Appointment Slots for Doctor's Shift:");
        for (ShiftSlot s : slots) {
            System.out.println("  - " + s);
        }
        System.out.println();

        ScheduleResult greedyRes = scheduleGreedy(slots);
        ScheduleResult dpRes = scheduleDynamicProgramming(slots);

        System.out.println("1. Greedy Selection (Earliest Finish Time First):");
        System.out.println("   - Greedy greedily selects 'Minor Clinic A' (finishes earliest at 09:30).");
        System.out.println("   - This blocks the 'Major Surgery B' (which started at 09:00).");
        System.out.println("   - Next, Greedy picks 'Routine Followup' (12:30-13:30), then 'Cardiology Proc' (13:30-16:00).");
        System.out.printf("   => GREEDY RESULT: Total Value = %d pts | Appointments: %s%n%n",
                greedyRes.totalWeight, greedyRes.selected);

        System.out.println("2. Dynamic Programming Optimal Selection (Weighted Subproblem Tabulation):");
        System.out.println("   - DP evaluates choice at each interval: Include vs Exclude.");
        System.out.println("   - DP recognizes Major Surgery (180) + Cardiology (140) = 320 pts > Greedy's 200 pts!");
        System.out.printf("   => DP OPTIMAL RESULT: Total Value = %d pts | Appointments: %s%n%n",
                dpRes.totalWeight, dpRes.selected);

        System.out.println("+----------------------+-------------------+-----------------------+------------------+");
        System.out.println("| Algorithm            | Total Care Value  | Appointments Accepted | Optimality       |");
        System.out.println("+----------------------+-------------------+-----------------------+------------------+");
        System.out.printf("| Greedy Approach      | %14d pts | %,21d | SUB-OPTIMAL      |%n",
                greedyRes.totalWeight, greedyRes.selected.size());
        System.out.printf("| Dynamic Programming  | %14d pts | %,21d | OPTIMAL (+60%%)   |%n",
                dpRes.totalWeight, dpRes.selected.size());
        System.out.println("+----------------------+-------------------+-----------------------+------------------+");

        System.out.println("\n--- Algorithmic Conclusion ---");
        System.out.println("1. When appointment durations and patient acuity weights vary, the greedy-choice property fails.");
        System.out.println("2. Dynamic Programming computes the true globally optimal shift roster in O(n log n) time,");
        System.out.println("   maximizing physician clinical productivity and patient care outcome metrics.\n");
    }
}
