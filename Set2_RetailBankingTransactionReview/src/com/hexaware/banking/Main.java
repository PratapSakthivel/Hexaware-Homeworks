package com.hexaware.banking;

import com.hexaware.banking.model.Transaction;
import com.hexaware.banking.task1.TransactionSearchBenchmark;
import com.hexaware.banking.task2.StatementSortBenchmark;
import com.hexaware.banking.task3.DuplicatePostingDetector;
import com.hexaware.banking.task4.ReviewBacklogAndReversalDemo;
import com.hexaware.banking.task5.ExtremeAmountFinder;
import com.hexaware.banking.util.TransactionGenerator;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * Master Main entry point for Set 2: Retail Banking Transaction Review.
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

            String csvPath = "data/transactions.csv";
            System.out.println(">>> STEP 0: INITIALIZING DATASET (100,000 TRANSACTIONS)");
            TransactionGenerator.generateCsvIfMissing(csvPath, TransactionGenerator.TOTAL_TRANSACTIONS);
            List<Transaction> transactions = TransactionGenerator.loadTransactions(csvPath);
            System.out.printf("[Banking Data] Loaded %,d transactions into memory.%n%n", transactions.size());

            // TASK 1: Binary Search vs Linear Search (100k records)
            TransactionSearchBenchmark.runBenchmark(transactions);

            // TASK 2: Statement Sorting by Posting Date & Stability
            StatementSortBenchmark.runDemo(transactions);

            // TASK 3: Duplicate Posting Detection (Within 60 Seconds)
            DuplicatePostingDetector.runDemo(transactions);

            // TASK 4: Custom Queue (Backlog) & Custom Stack (Adjustment Reversal)
            ReviewBacklogAndReversalDemo.runDemo(transactions);

            // TASK 5: Extreme Amount Finder (Divide-and-Conquer vs Brute-Force)
            ExtremeAmountFinder.runDemo(transactions);

            System.out.println("================================================================================");
            System.out.println("   SET 2: ALL TASKS COMPLETED SUCCESSFULLY!");
            System.out.println("   Console output mirrored to: console_output.txt");
            System.out.println("   Complexity and rationale report: COMPLEXITY_AND_RATIONALE.md");
            System.out.println("================================================================================");

        } catch (Exception e) {
            e.printStackTrace(originalOut);
        } finally {
            System.setOut(originalOut);
        }
    }

    private static void printBanner() {
        System.out.println("################################################################################");
        System.out.println("#              SET 2 – RETAIL BANKING TRANSACTION REVIEW                       #");
        System.out.println("#      Core Banking Transaction Processing & Algorithmic Audit Suite           #");
        System.out.println("################################################################################");
        System.out.println();
    }
}
