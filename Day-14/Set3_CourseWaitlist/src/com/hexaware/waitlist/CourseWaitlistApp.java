package com.hexaware.waitlist;

import java.util.*;

public class CourseWaitlistApp {
    public static void main(String[] args) {
        System.out.println("==========================================================================");
        System.out.println("                ENTERPRISE TRAINING COURSE WAITLIST DESK                 ");
        System.out.println("==========================================================================\n");

        List<LearnerRegistration> rawRegs = List.of(
            new LearnerRegistration("LRN-101", "Aakash Gupta", 3, 1000L, 88),
            new LearnerRegistration("LRN-102", "Bhavna Patel", 7, 1020L, 95),
            new LearnerRegistration("LRN-101", "Aakash G.",    3, 1000L, 88), // Duplicate
            new LearnerRegistration("LRN-103", "Chirag Sethi", 7, 1010L, 78),
            new LearnerRegistration("LRN-104", "Divya Menon",  5, 1040L, 92)
        );

        // Task 2: Deduplication via HashSet
        Set<LearnerRegistration> uniqueSet = new HashSet<>(rawRegs);
        System.out.printf("Raw Registrations: %d | Duplicates Removed: %d%n%n",
            rawRegs.size(), rawRegs.size() - uniqueSet.size());

        // Task 1: PriorityQueue Promoting Seniority then Timestamp
        PriorityQueue<LearnerRegistration> waitlistQueue = new PriorityQueue<>(uniqueSet);
        System.out.println("--- Promoted Waitlist Roster (PriorityQueue Order) ---");
        while (!waitlistQueue.isEmpty()) {
            System.out.println("ADMITTED: " + waitlistQueue.poll());
        }

        // Task 4: Wildcard method summing course capacities
        List<Course> courses = List.of(
            new Course("CS-101", "Cloud Architecture", 30),
            new Course("CS-102", "Advanced Microservices", 25)
        );
        System.out.printf("%nTotal Enterprise Training Capacity: %d seats%n", sumCapacity(courses));

        // Task 5: 4 Utility methods (Arrays & Collections)
        List<String> names = new ArrayList<>(Arrays.asList("Divya", "Chirag", "Bhavna", "Aakash"));
        Collections.sort(names);                                                // 1. sort
        int idx = Collections.binarySearch(names, "Bhavna");                    // 2. binarySearch
        Collections.reverse(names);                                             // 3. reverse
        List<String> unmodifiable = Collections.unmodifiableList(names);         // 4. unmodifiableList
        System.out.println("Utility Demonstration Index of 'Bhavna': " + idx + " | Reversed: " + unmodifiable);
    }

    public static int sumCapacity(List<? extends Course> list) {
        int sum = 0;
        for (Course c : list) sum += c.getCapacity();
        return sum;
    }
}
