package com.hexaware.retail;

import com.hexaware.retail.model.Order;
import com.hexaware.retail.task1.SearchBenchmark;
import com.hexaware.retail.task2.SortBenchmark;
import com.hexaware.retail.task3.DuplicateDetector;
import com.hexaware.retail.task4.DispatchAndUndoDemo;
import com.hexaware.retail.task5.RefundCalculator;
import com.hexaware.retail.util.CsvOrderGenerator;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * Main Entry Point for Set 1 – Retail Order Desk
 * Coordinates and executes all 5 core business tasks,
 * printing formatted output and saving the full console report.
 */
public class Main {

    public static void main(String[] args) {
        PrintStream originalOut = System.out;
        File logFile = new File("console_output.txt");

        try (FileOutputStream fos = new FileOutputStream(logFile)) {

            OutputStream tee = new OutputStream() {
                @Override
                public void write(int b) throws IOException {
                    originalOut.write(b);
                    fos.write(b);
                }

                @Override
                public void write(byte[] b, int off, int len) throws IOException {
                    originalOut.write(b, off, len);
                    fos.write(b, off, len);
                }

                @Override
                public void flush() throws IOException {
                    originalOut.flush();
                    fos.flush();
                }
            };

            PrintStream dualStream = new PrintStream(tee, true, StandardCharsets.UTF_8.name());
            System.setOut(dualStream);

            printBanner();

            String csvPath = "data/orders.csv";
            System.out.println(">>> STEP 0: INITIALIZING DATASET (50,000 ORDERS)");
            CsvOrderGenerator.generateCsvIfMissing(csvPath, CsvOrderGenerator.TOTAL_ORDERS);
            List<Order> orders = CsvOrderGenerator.loadOrders(csvPath);
            System.out.printf("[Data] Successfully loaded %,d orders into active memory.%n%n", orders.size());

            // TASK 1: Linear Search vs Binary Search
            SearchBenchmark.runBenchmark(orders);

            // TASK 2: O(n^2) vs O(n log n) vs Built-in Sort
            SortBenchmark.runBenchmark(orders);

            // TASK 3: Duplicate Order Detection with Hash-based structure
            DuplicateDetector.runDuplicateDetection(orders);

            // TASK 4: Custom Stack & Queue vs Built-in Equivalents
            DispatchAndUndoDemo.runDemo(orders);

            // TASK 5: Refund Coin Change - Greedy vs Dynamic Programming
            RefundCalculator.runRefundDemo();

            System.out.println("================================================================================");
            System.out.println("   ALL 5 TASKS COMPLETED SUCCESSFULLY!");
            System.out.println("   Console output mirrored to: console_output.txt");
            System.out.println("   One-page complexity & rationale note saved to: COMPLEXITY_AND_RATIONALE.md");
            System.out.println("================================================================================");

        } catch (Exception e) {
            e.printStackTrace(originalOut);
        } finally {
            System.setOut(originalOut);
        }
    }

    private static void printBanner() {
        System.out.println("################################################################################");
        System.out.println("#                      SET 1 – RETAIL ORDER DESK                               #");
        System.out.println("#      Enterprise High-Performance Order Processing & Algorithm Suite          #");
        System.out.println("################################################################################");
        System.out.println();
    }
}
