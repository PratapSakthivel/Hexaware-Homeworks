package com.hexaware.hospital.task4;

import com.hexaware.hospital.model.Patient;

import java.util.List;

/**
 * Task 4: Walk-in Token Line (Queue) & Recent Patients Viewed (Stack).
 * Demonstrates real-world clinical workflow using custom data structures built from scratch.
 */
public class TokenLineAndHistoryDemo {

    public static void runDemo(List<Patient> patients) {
        System.out.println("================================================================================");
        System.out.println("   TASK 4: WALK-IN TOKEN LINE (QUEUE) & RECENT PATIENTS VIEWED (STACK)");
        System.out.println("================================================================================");

        // ---------------------------------------------------------------------
        // PART 1: WALK-IN TOKEN LINE (FIFO QUEUE)
        // ---------------------------------------------------------------------
        System.out.println("--- Part 1: Walk-In Token Line (CustomQueue - FIFO) ---");
        CustomQueue<Patient> tokenQueue = new CustomQueue<>();

        int count = Math.min(5, patients.size());
        System.out.println("Reception issuing walk-in tokens to arriving patients:");
        for (int i = 0; i < count; i++) {
            Patient p = patients.get(i);
            tokenQueue.enqueue(p);
            System.out.printf("  [Token #%d] Issued to: %s (Age: %d)%n", i + 1, p.getName(), p.getAge());
        }

        System.out.printf("%nTriage Nurse calling patients in FIFO order:%n");
        int tokenNum = 1;
        while (!tokenQueue.isEmpty()) {
            Patient called = tokenQueue.dequeue();
            System.out.printf("  [Call #%d] Now Serving: %s (ID: %d) | Waiting in lobby: %d%n",
                    tokenNum++, called.getName(), called.getPatientId(), tokenQueue.size());
        }

        // ---------------------------------------------------------------------
        // PART 2: RECENT PATIENTS VIEWED HISTORY (LIFO STACK)
        // ---------------------------------------------------------------------
        System.out.println("\n-------------------------------------------------------------------------");
        System.out.println("--- Part 2: Doctor's 'Recent Patients Viewed' Navigation (CustomStack - LIFO) ---");
        System.out.println("-------------------------------------------------------------------------");

        CustomStack<Patient> recentStack = new CustomStack<>();

        System.out.println("Doctor Dr. Henderson opens clinical charts sequentially:");
        for (int i = 0; i < 4; i++) {
            Patient p = patients.get(i);
            recentStack.push(p);
            System.out.printf("  [Chart Viewed] %s (ID: %d, Phone: %s) -> History depth: %d%n",
                    p.getName(), p.getPatientId(), p.getContactNumber(), recentStack.size());
        }

        System.out.printf("%nDoctor clicks 'Back / Previous Chart' button (LIFO Navigation):%n");
        while (!recentStack.isEmpty()) {
            Patient prev = recentStack.pop();
            System.out.printf("  <- Returned to Chart: %s (ID: %d) | History remaining: %d%n",
                    prev.getName(), prev.getPatientId(), recentStack.size());
        }

        System.out.println("\n--- Data Structure Justification ---");
        System.out.println("1. Walk-In Line (Queue - FIFO): Guarantees strict fairness. Arriving patients are served");
        System.out.println("   in the exact sequence they received tokens, preventing dispute and queue-jumping.");
        System.out.println("2. Recent Patients History (Stack - LIFO): The medical chart viewed most recently");
        System.out.println("   must be the immediate candidate when hitting 'Back', perfectly adhering to LIFO semantics.\n");
    }
}
