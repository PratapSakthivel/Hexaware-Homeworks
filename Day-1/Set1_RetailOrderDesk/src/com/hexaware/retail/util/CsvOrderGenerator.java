package com.hexaware.retail.util;

import com.hexaware.retail.model.Order;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;

/**
 * Utility to generate and load realistic 50,000 order records into orders.csv.
 */
public class CsvOrderGenerator {

    public static final String DEFAULT_CSV_PATH = "data/orders.csv";
    public static final int TOTAL_ORDERS = 50_000;

    /**
     * Generates orders.csv with 50,000 records, including deliberate duplicates for Task 3.
     */
    public static void generateCsvIfMissing(String csvPath, int count) throws IOException {
        File file = new File(csvPath);
        if (file.exists() && file.length() > 0) {
            System.out.println("[Data] Found existing orders CSV at: " + csvPath + " (" + file.length() / 1024 + " KB)");
            return;
        }

        File parentDir = file.getParentFile();
        if (parentDir != null && !parentDir.exists()) {
            parentDir.mkdirs();
        }

        System.out.println("[Data] Generating " + count + " order records in: " + csvPath + " ...");
        Random random = new Random(42); // deterministic seed for reproducibility
        LocalDateTime baseTime = LocalDateTime.of(2026, 10, 29, 8, 0, 0);

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            writer.write("orderId,customerId,amount,createdAt\n");

            // We will inject 6 explicit duplicate pairs across the dataset for Task 3 verification
            Map<Integer, String> deliberateDuplicates = new HashMap<>();
            // Indices where duplicates will be planted:
            // e.g. order 505 duplicates order 500, order 1205 duplicates order 1200, etc.
            int[] dupBases = {500, 1200, 7500, 18000, 32000, 48000};
            int[] dupTargets = {505, 1205, 7506, 18008, 32004, 48003};

            Map<Integer, Order> baseRecords = new HashMap<>();

            for (int i = 1; i <= count; i++) {
                int orderId = 100_000 + i;
                String customerId;
                double amount;
                LocalDateTime createdAt;

                // Check if this index is a targeted duplicate
                int dupIndex = -1;
                for (int d = 0; d < dupTargets.length; d++) {
                    if (dupTargets[d] == i) {
                        dupIndex = d;
                        break;
                    }
                }

                if (dupIndex != -1) {
                    // Replicate customerId and amount from the base order, and set createdAt within same minute (+15s)
                    Order base = baseRecords.get(dupBases[dupIndex]);
                    customerId = base.getCustomerId();
                    amount = base.getAmount();
                    createdAt = base.getCreatedAt().plusSeconds(18); // within the same minute!
                } else {
                    int custNum = 1000 + random.nextInt(8000);
                    customerId = "CUST-" + custNum;
                    // Random amount between 10.00 and 2500.00 rounded to 2 decimal places
                    amount = Math.round((10.0 + (random.nextDouble() * 2490.0)) * 100.0) / 100.0;
                    // Timestamp spread across a 24-hour workday (86400 seconds)
                    int secondsOffset = random.nextInt(86400);
                    createdAt = baseTime.plusSeconds(secondsOffset);
                }

                // If this is a base for future duplicate, remember it
                for (int b : dupBases) {
                    if (b == i) {
                        baseRecords.put(i, new Order(orderId, customerId, amount, createdAt));
                        break;
                    }
                }

                writer.write(orderId + "," + customerId + "," + String.format(Locale.US, "%.2f", amount) + "," + createdAt.format(Order.ISO_FORMATTER) + "\n");
            }
        }
        System.out.println("[Data] Successfully created " + csvPath + " with " + count + " records.");
    }

    /**
     * Reads all orders from CSV file into an ArrayList.
     */
    public static List<Order> loadOrders(String csvPath) throws IOException {
        List<Order> orders = new ArrayList<>(TOTAL_ORDERS);
        try (BufferedReader reader = new BufferedReader(new FileReader(csvPath))) {
            String line = reader.readLine(); // Header
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] parts = line.split(",");
                if (parts.length >= 4) {
                    int orderId = Integer.parseInt(parts[0].trim());
                    String customerId = parts[1].trim();
                    double amount = Double.parseDouble(parts[2].trim());
                    LocalDateTime createdAt = LocalDateTime.parse(parts[3].trim(), Order.ISO_FORMATTER);
                    orders.add(new Order(orderId, customerId, amount, createdAt));
                }
            }
        }
        return orders;
    }
}
