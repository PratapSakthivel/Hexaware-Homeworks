package com.hexaware.banking.util;

import com.hexaware.banking.model.Transaction;

import java.io.*;
import java.time.LocalDateTime;
import java.util.*;

/**
 * Utility to generate and load 100,000 realistic banking transactions.
 */
public class TransactionGenerator {

    public static final String DEFAULT_CSV_PATH = "data/transactions.csv";
    public static final int TOTAL_TRANSACTIONS = 100_000;

    private static final String[] MERCHANTS = {
            "Amazon Retail", "Walmart Supercenter", "Starbucks Coffee", "Shell Oil",
            "Apple Store", "Uber Technologies", "Target Stores", "Netflix Subscriptions",
            "McDonalds", "Costco Wholesale", "Kroger Grocery", "Delta Airlines"
    };

    public static void generateCsvIfMissing(String csvPath, int count) throws IOException {
        File file = new File(csvPath);
        if (file.exists() && file.length() > 0) {
            System.out.println("[Banking Data] Found existing transactions CSV at: " + csvPath + " (" + file.length() / 1024 + " KB)");
            return;
        }

        File parent = file.getParentFile();
        if (parent != null && !parent.exists()) {
            parent.mkdirs();
        }

        System.out.printf("[Banking Data] Generating %,d transactions in: %s ...%n", count, csvPath);
        Random rand = new Random(101); // deterministic seed
        LocalDateTime baseTime = LocalDateTime.of(2026, 10, 29, 0, 0, 0);

        try (BufferedWriter bw = new BufferedWriter(new FileWriter(file))) {
            bw.write("transactionId,accountId,amount,merchant,postingDate,originalSequence\n");

            // Plan 5 explicit duplicate posting pairs for Task 3:
            // same account, amount, merchant within 60 seconds
            int[] dupBases = {1200, 15000, 35000, 68000, 92000};
            int[] dupTargets = {1204, 15003, 35002, 68004, 92002};
            Map<Integer, Transaction> baseTxns = new HashMap<>();

            for (int i = 1; i <= count; i++) {
                long txnId = 10_000_000L + i; // Sorted transaction ID
                String accountId;
                double amount;
                String merchant;
                LocalDateTime postingDate;
                int seq = i;

                int dupIdx = -1;
                for (int d = 0; d < dupTargets.length; d++) {
                    if (dupTargets[d] == i) {
                        dupIdx = d;
                        break;
                    }
                }

                if (dupIdx != -1) {
                    Transaction base = baseTxns.get(dupBases[dupIdx]);
                    accountId = base.getAccountId();
                    amount = base.getAmount();
                    merchant = base.getMerchant();
                    // Posted 22 seconds later (within 60 seconds)
                    postingDate = base.getPostingDate().plusSeconds(22);
                } else {
                    int accNum = 1000 + rand.nextInt(5000);
                    accountId = "ACC-" + accNum;
                    merchant = MERCHANTS[rand.nextInt(MERCHANTS.length)];
                    amount = Math.round((2.50 + rand.nextDouble() * 4997.50) * 100.0) / 100.0;
                    int secondsOffset = rand.nextInt(86400); // within 24h
                    postingDate = baseTime.plusSeconds(secondsOffset);
                }

                for (int b : dupBases) {
                    if (b == i) {
                        baseTxns.put(i, new Transaction(txnId, accountId, amount, merchant, postingDate, seq));
                        break;
                    }
                }

                bw.write(String.format(Locale.US, "%d,%s,%.2f,%s,%s,%d\n",
                        txnId, accountId, amount, merchant, postingDate.format(Transaction.FORMATTER), seq));
            }
        }
        System.out.println("[Banking Data] Successfully generated transactions CSV.");
    }

    public static List<Transaction> loadTransactions(String csvPath) throws IOException {
        List<Transaction> list = new ArrayList<>(TOTAL_TRANSACTIONS);
        try (BufferedReader br = new BufferedReader(new FileReader(csvPath))) {
            String line = br.readLine(); // Header
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] parts = line.split(",");
                if (parts.length >= 6) {
                    long id = Long.parseLong(parts[0].trim());
                    String acc = parts[1].trim();
                    double amt = Double.parseDouble(parts[2].trim());
                    String merch = parts[3].trim();
                    LocalDateTime date = LocalDateTime.parse(parts[4].trim(), Transaction.FORMATTER);
                    int seq = Integer.parseInt(parts[5].trim());
                    list.add(new Transaction(id, acc, amt, merch, date, seq));
                }
            }
        }
        return list;
    }
}
