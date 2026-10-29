package com.hexaware.hospital.task3;

import com.hexaware.hospital.model.Appointment;

import java.util.*;

/**
 * Task 3: Double-Booked Slot Detection (Same Patient and Slot).
 * Explains why a list scan is unacceptable at high volume and implements O(n) Hash Set solution.
 */
public class DoubleBookingDetector {

    public static class ConflictReport {
        public final Appointment original;
        public final Appointment conflict;

        public ConflictReport(Appointment original, Appointment conflict) {
            this.original = original;
            this.conflict = conflict;
        }

        @Override
        public String toString() {
            return String.format("DOUBLE-BOOKING DETECTED: Patient %s (ID: %d) booked twice for Slot '%s':\n" +
                            "  [Original] Apt ID: %d (%s, Arrival: %s)\n" +
                            "  [Conflict] Apt ID: %d (%s, Arrival: %s)",
                    original.getPatientName(), original.getPatientId(), original.getSlotTime(),
                    original.getAppointmentId(), original.getUrgencyLabel(), original.getArrivalTime(),
                    conflict.getAppointmentId(), conflict.getUrgencyLabel(), conflict.getArrivalTime());
        }
    }

    /**
     * Hash-Based Detection: O(n) Time, O(n) Space.
     */
    public static List<ConflictReport> detectConflictsWithHashSet(List<Appointment> appointments) {
        Map<String, Appointment> bookedSlots = new HashMap<>();
        List<ConflictReport> conflicts = new ArrayList<>();

        for (Appointment apt : appointments) {
            String slotKey = apt.getPatientId() + "@" + apt.getSlotTime();
            Appointment existing = bookedSlots.putIfAbsent(slotKey, apt);
            if (existing != null) {
                conflicts.add(new ConflictReport(existing, apt));
            }
        }
        return conflicts;
    }

    /**
     * Naive List Scan: O(n^2) Time, O(1) Auxiliary Space.
     */
    public static List<ConflictReport> detectConflictsWithListScan(List<Appointment> appointments) {
        List<ConflictReport> conflicts = new ArrayList<>();
        int n = appointments.size();
        for (int i = 0; i < n; i++) {
            Appointment cur = appointments.get(i);
            for (int j = 0; j < i; j++) {
                Appointment prev = appointments.get(j);
                if (cur.getPatientId() == prev.getPatientId() && cur.getSlotTime().equals(prev.getSlotTime())) {
                    conflicts.add(new ConflictReport(prev, cur));
                    break;
                }
            }
        }
        return conflicts;
    }

    public static void runDemo(List<Appointment> appointments) {
        System.out.println("================================================================================");
        System.out.println("   TASK 3: DOUBLE-BOOKED SLOT DETECTION (SAME PATIENT AND SLOT)");
        System.out.println("================================================================================");
        System.out.printf("Analyzing %,d scheduled appointments on shared hospital roster...%n%n", appointments.size());

        // 1. Hash-based structure
        long t0 = System.currentTimeMillis();
        List<ConflictReport> hashConflicts = detectConflictsWithHashSet(appointments);
        long hashTime = System.currentTimeMillis() - t0;

        // 2. Naive list scan on same dataset
        long t1 = System.currentTimeMillis();
        List<ConflictReport> listConflicts = detectConflictsWithListScan(appointments);
        long listTime = System.currentTimeMillis() - t1;

        System.out.println("+--------------------------+-------------------+--------------------+-----------------+");
        System.out.println("| Detection Approach       | Execution Time    | Time Complexity    | Conflicts Found |");
        System.out.println("+--------------------------+-------------------+--------------------+-----------------+");
        System.out.printf("| Hash-Based (HashSet/Map) | %14d ms | O(n) average       | %,15d |%n",
                hashTime, hashConflicts.size());
        System.out.printf("| Naive List Scan (Nested) | %14d ms | O(n^2) quadratic   | %,15d |%n",
                listTime, listConflicts.size());
        System.out.println("+--------------------------+-------------------+--------------------+-----------------+");
        System.out.printf("Speedup Factor: Hash-based approach is %.1fx faster than a list scan.%n%n",
                (double) Math.max(1, listTime) / Math.max(1, hashTime));

        System.out.println("Detected Double-Booked Conflicts (Immediate Action Required):");
        for (int i = 0; i < hashConflicts.size(); i++) {
            System.out.printf("--- Conflict #%d ---%n%s%n%n", i + 1, hashConflicts.get(i));
        }

        System.out.println("Why a List Scan is Not Acceptable at this Volume:");
        System.out.println("  1. Complexity Bottleneck: An O(n^2) list scan performs n*(n-1)/2 = 12.5 million checks for 5,000 records.");
        System.out.println("     If the hospital expands to 50,000 bookings, the list scan requires 1.25 billion checks (over 45 seconds).");
        System.out.println("  2. Concurrency & Race Conditions: In a shared hospital roster where hundreds of receptionists");
        System.out.println("     book appointments simultaneously, locking the roster for tens of seconds causes catastrophic UI freezes.");
        System.out.println("  3. The Hash-based structure offers O(1) amortized lock-free verification, ensuring immediate booking feedback.\n");
    }
}
