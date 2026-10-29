package com.hexaware.banking.task3;

import com.hexaware.banking.model.Transaction;

import java.time.temporal.ChronoUnit;
import java.util.*;

/**
 * Task 3: Duplicate Posting Detection (Within 60 Seconds)
 * Identifies duplicate card transactions: same account, amount, and merchant within 60s.
 * Justifies the choice of Hash Map with time and space complexity.
 */
public class DuplicatePostingDetector {

    public static class DuplicateAlert {
        public final Transaction original;
        public final Transaction duplicate;
        public final long secondsApart;

        public DuplicateAlert(Transaction original, Transaction duplicate, long secondsApart) {
            this.original = original;
            this.duplicate = duplicate;
            this.secondsApart = secondsApart;
        }

        @Override
        public String toString() {
            return String.format("ALERT: Account %s charged twice at '%s' for $%.2f (%d sec apart)\n" +
                            "  [1] ID: %d at %s\n  [2] ID: %d at %s",
                    original.getAccountId(), original.getMerchant(), original.getAmount(), secondsApart,
                    original.getTransactionId(), original.getPostingDate().format(Transaction.FORMATTER),
                    duplicate.getTransactionId(), duplicate.getPostingDate().format(Transaction.FORMATTER));
        }
    }

    /**
     * Detects duplicate postings using a Hash Map with composite key.
     * Time Complexity: O(n) average time.
     * Space Complexity: O(n) auxiliary space.
     */
    public static List<DuplicateAlert> findDuplicates(List<Transaction> transactions) {
        // Map key: AccountId|Merchant|Amount
        Map<String, List<Transaction>> map = new HashMap<>();
        List<DuplicateAlert> alerts = new ArrayList<>();

        for (Transaction current : transactions) {
            String key = current.getAccountId() + "|" + current.getMerchant() + "|" +
                    String.format(Locale.US, "%.2f", current.getAmount());

            List<Transaction> matches = map.get(key);
            if (matches != null) {
                for (Transaction prev : matches) {
                    long diff = Math.abs(ChronoUnit.SECONDS.between(prev.getPostingDate(), current.getPostingDate()));
                    if (diff <= 60) {
                        alerts.add(new DuplicateAlert(prev, current, diff));
                        break;
                    }
                }
                matches.add(current);
            } else {
                List<Transaction> list = new ArrayList<>();
                list.add(current);
                map.put(key, list);
            }
        }
        return alerts;
    }

    public static void runDemo(List<Transaction> transactions) {
        System.out.println("================================================================================");
        System.out.println("   TASK 3: DUPLICATE POSTING IDENTIFICATION (SAME ACCOUNT, AMT, MERCH <= 60s)");
        System.out.println("================================================================================");
        System.out.printf("Scanning %,d transactions for rapid double-charge postings...%n%n", transactions.size());

        long start = System.currentTimeMillis();
        List<DuplicateAlert> alerts = findDuplicates(transactions);
        long elapsed = System.currentTimeMillis() - start;

        System.out.println("+-------------------------------------------------------------------------------+");
        System.out.printf("| Total Transactions Analyzed : %,d%n", transactions.size());
        System.out.printf("| Duplicate Postings Flagged  : %d alerts%n", alerts.size());
        System.out.printf("| Processing Time             : %d ms%n", elapsed);
        System.out.println("+-------------------------------------------------------------------------------+");

        System.out.println("\nEarly Warning Alerts (Sent to Fraud & Operations Desk):");
        for (int i = 0; i < alerts.size(); i++) {
            System.out.printf("--- Incident #%d ---%n%s%n%n", i + 1, alerts.get(i));
        }

        System.out.println("--- Data Structure Justification & Complexity ---");
        System.out.println("1. Data Structure Choice: HashMap<String, List<Transaction>> with composite key.");
        System.out.println("2. Time Complexity: O(n) average.");
        System.out.println("   - Hashing the composite string (Account + Merchant + Amount) takes O(1) amortized time.");
        System.out.println("   - Each bucket contains only a tiny number of transactions (usually 1-2), making the 60s comparison O(1).");
        System.out.println("   - In contrast, a naive pairwise check takes O(n^2) = ~5 billion comparisons for 100k transactions!");
        System.out.println("3. Space Complexity: O(n) to store references in the hash table.");
        System.out.println("   - For 100,000 daily transactions, memory footprint is under 10 MB, perfectly suited for real-time stream ingestion.\n");
    }
}
