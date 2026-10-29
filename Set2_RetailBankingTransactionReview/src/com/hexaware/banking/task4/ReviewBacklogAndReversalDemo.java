package com.hexaware.banking.task4;

import com.hexaware.banking.model.Adjustment;
import com.hexaware.banking.model.Transaction;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.List;
import java.util.Queue;

/**
 * Task 4: Queue (Manual-Review Backlog) and Stack (Reverse Last Adjustment).
 * Demonstrates operations using custom implementations, followed by library comparisons.
 */
public class ReviewBacklogAndReversalDemo {

    public static void runDemo(List<Transaction> transactions) {
        System.out.println("================================================================================");
        System.out.println("   TASK 4: MANUAL REVIEW BACKLOG (QUEUE) & ADJUSTMENT REVERSAL (STACK)");
        System.out.println("================================================================================");

        // ---------------------------------------------------------------------
        // PART 1: MANUAL-REVIEW BACKLOG USING CUSTOM QUEUE (FIFO)
        // ---------------------------------------------------------------------
        System.out.println("--- Part 1: Operations Manual-Review Backlog (CustomQueue - FIFO) ---");
        CustomQueue<Transaction> backlog = new CustomQueue<>();

        // Enqueue 4 flagged suspicious transactions
        int count = Math.min(4, transactions.size());
        for (int i = 0; i < count; i++) {
            Transaction t = transactions.get(i);
            backlog.enqueue(t);
            System.out.printf("  [+] Enqueued for Audit: Txn #%d (Account: %s, Merchant: '%s', Amount: $%.2f)%n",
                    t.getTransactionId(), t.getAccountId(), t.getMerchant(), t.getAmount());
        }

        System.out.printf("%nAuditor reviewing backlog from front of queue (FIFO):%n");
        while (!backlog.isEmpty()) {
            Transaction reviewed = backlog.dequeue();
            System.out.printf("  [-] Reviewed & Cleared: Txn #%d ($%.2f at %s) | Backlog remaining: %d%n",
                    reviewed.getTransactionId(), reviewed.getAmount(), reviewed.getMerchant(), backlog.size());
        }

        // ---------------------------------------------------------------------
        // PART 2: REVERSE LAST ADJUSTMENT USING CUSTOM STACK (LIFO)
        // ---------------------------------------------------------------------
        System.out.println("\n-------------------------------------------------------------------------");
        System.out.println("--- Part 2: Reverse Last Adjustment (CustomStack - LIFO) ---");
        System.out.println("-------------------------------------------------------------------------");

        String accountId = "ACC-9901";
        double currentBalance = 150.00;
        System.out.printf("Account: %s | Starting Balance: $%.2f%n%n", accountId, currentBalance);

        CustomStack<Adjustment> adjustmentHistory = new CustomStack<>();

        // Agent applies 3 adjustments
        System.out.println("[Agent Applying Adjustments]");
        Adjustment a1 = new Adjustment(accountId, 35.00, "WAIVE_OVERDRAFT_FEE");
        currentBalance += a1.getAdjustmentAmount();
        adjustmentHistory.push(a1);
        System.out.printf("  1. Applied +$35 fee waiver      -> Balance: $%.2f | Stack size: %d%n", currentBalance, adjustmentHistory.size());

        Adjustment a2 = new Adjustment(accountId, 120.00, "CREDIT_DISPUTED_CHARGE");
        currentBalance += a2.getAdjustmentAmount();
        adjustmentHistory.push(a2);
        System.out.printf("  2. Applied +$120 dispute credit -> Balance: $%.2f | Stack size: %d%n", currentBalance, adjustmentHistory.size());

        Adjustment a3 = new Adjustment(accountId, 500.00, "ERRONEOUS_MANUAL_CREDIT");
        currentBalance += a3.getAdjustmentAmount();
        adjustmentHistory.push(a3);
        System.out.printf("  3. Applied +$500 mistaken credit-> Balance: $%.2f | Stack size: %d%n", currentBalance, adjustmentHistory.size());

        // Reverse last adjustment (Mistaken credit)
        System.out.println("\n[Auditor Rolling Back Mistakes via LIFO Stack]");
        while (!adjustmentHistory.isEmpty()) {
            Adjustment last = adjustmentHistory.pop();
            currentBalance -= last.getAdjustmentAmount();
            System.out.printf("  <- REVERSED: %s of $%.2f | Restored Balance: $%.2f (History size: %d)%n",
                    last.getAdjustmentType(), last.getAdjustmentAmount(), currentBalance, adjustmentHistory.size());
        }

        // ---------------------------------------------------------------------
        // PART 3: COMPARISON WITH BUILT-IN EQUIVALENTS (ArrayDeque)
        // ---------------------------------------------------------------------
        System.out.println("\n-------------------------------------------------------------------------");
        System.out.println("--- Part 3: Comparison with Java Standard Library (ArrayDeque) ---");
        System.out.println("-------------------------------------------------------------------------");

        Queue<Transaction> libQueue = new ArrayDeque<>();
        Deque<Adjustment> libStack = new ArrayDeque<>();

        libQueue.offer(transactions.get(0));
        libStack.push(a1);

        System.out.printf("  Built-in Queue peek : %s%n", libQueue.peek());
        System.out.printf("  Built-in Stack peek : %s%n", libStack.peek());

        System.out.println("\nTakeaways & Architecture:");
        System.out.println("  1. Custom Queue uses circular buffer arithmetic to achieve O(1) enqueue and dequeue without shifting elements.");
        System.out.println("  2. Custom Stack uses geometric capacity doubling, giving O(1) amortized push and pop.");
        System.out.println("  3. Library ArrayDeque achieves similar performance, but building from scratch ensures no hidden framework overhead.\n");
    }
}
