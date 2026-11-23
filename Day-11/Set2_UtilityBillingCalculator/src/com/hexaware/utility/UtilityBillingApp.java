package com.hexaware.utility;

import java.util.Scanner;

/**
 * Day 11 - Set 2: Utility Billing Calculator (JDK 25 LTS)
 * Computes electric utility bills across 4 graduated consumption slabs,
 * consumer category fixed charges, late surcharges, and digital rebates.
 * Demonstrates operator precedence, 12-month simulation for-loop, do-while loop,
 * and primitive casting/overflow traps with mitigations.
 */
public class UtilityBillingApp {

    public enum Category { DOMESTIC, COMMERCIAL, INDUSTRIAL }

    public record BillBreakdown(
        double slabEnergyCharge,
        double fixedCharge,
        double lateSurcharge,
        double onlineRebate,
        double netBillAmount
    ) {}

    public static void main(String[] args) {
        System.out.println("===============================================================================");
        System.out.println("                    STATE ELECTRICITY UTILITY BILLING SYSTEM                   ");
        System.out.println("===============================================================================\n");

        // 1. Boundary Test Runs (Tasks 1, 2, 3)
        System.out.println("--- 1. Boundary Test Value Suite ---");
        int[] boundaryValues = {100, 101, 200, 201, 400, 401};
        for (int units : boundaryValues) {
            var bill = calculateBill(units, Category.DOMESTIC, true, true);
            System.out.printf("Units: %-4d | Category: DOMESTIC | Energy: ₹%-8.2f | Fixed: ₹%-6.2f | Surcharge: ₹%-6.2f | Rebate: ₹%-6.2f | Net: ₹%.2f%n",
                units, bill.slabEnergyCharge(), bill.fixedCharge(), bill.lateSurcharge(), bill.onlineRebate(), bill.netBillAmount());
        }

        // 2. 12-Month Customer Statement Simulation (Task 4)
        System.out.println("\n--- 2. 12-Month Simulated Consumption Statement (Commercial Consumer) ---");
        int[] monthlyUsage = {220, 240, 310, 450, 520, 490, 380, 290, 260, 300, 275, 340};
        String[] months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

        System.out.printf("%-6s | %-12s | %-14s | %-12s | %-12s%n", "MONTH", "UNITS USED", "ENERGY CHARGE", "SURCHARGE", "NET PAYABLE");
        System.out.println("------------------------------------------------------------------");
        double annualTotal = 0.0;
        for (int i = 0; i < monthlyUsage.length; i++) {
            var monthlyBill = calculateBill(monthlyUsage[i], Category.COMMERCIAL, false, true);
            annualTotal += monthlyBill.netBillAmount();
            System.out.printf("%-6s | %-12d | ₹%-13.2f | ₹%-11.2f | ₹%.2f%n",
                months[i], monthlyUsage[i], monthlyBill.slabEnergyCharge(), monthlyBill.lateSurcharge(), monthlyBill.netBillAmount());
        }
        System.out.println("------------------------------------------------------------------");
        System.out.printf("ANNUAL NET REVENUE COLLECTED: ₹%.2f%n%n", annualTotal);

        // 3. Demonstrating Primitive Casting & Overflow Traps (Task 5)
        demonstratePrimitivePitfalls();
    }

    /**
     * Calculates bill using 4 progressive slabs and consumer category fixed charges.
     */
    public static BillBreakdown calculateBill(int units, Category category, boolean isLate, boolean isOnline) {
        double energyCharge = 0.0;

        // Task 1: Four Consumption Slabs
        // Slab 1: 0 - 100 units @ ₹3.00/unit
        // Slab 2: 101 - 200 units @ ₹4.50/unit
        // Slab 3: 201 - 400 units @ ₹6.50/unit
        // Slab 4: Above 400 units @ ₹8.00/unit
        if (units <= 100) {
            energyCharge = units * 3.00;
        } else if (units <= 200) {
            energyCharge = (100 * 3.00) + ((units - 100) * 4.50);
        } else if (units <= 400) {
            energyCharge = (100 * 3.00) + (100 * 4.50) + ((units - 200) * 6.50);
        } else {
            energyCharge = (100 * 3.00) + (100 * 4.50) + (200 * 6.50) + ((units - 400) * 8.00);
        }

        // Task 2: Enhanced Switch Expression for Category Fixed Charge
        double fixedCharge = switch (category) {
            case DOMESTIC   -> 80.00;
            case COMMERCIAL -> 250.00;
            case INDUSTRIAL -> 800.00;
        };

        // Task 3: Late Surcharge (5%) & Online Rebate (2%)
        // Operator Precedence Note in Code:
        // Expression: energyCharge + fixedCharge + (isLate ? subtotal * 0.05 : 0.0) - (isOnline ? subtotal * 0.02 : 0.0)
        // Grouping parentheses () take highest precedence (Level 1),
        // followed by multiplicative operators (*), additive operators (+, -), and ternary operator (?:).
        double subtotal = energyCharge + fixedCharge;
        double lateSurcharge = isLate ? (subtotal * 0.05) : 0.00;
        double onlineRebate = isOnline ? (subtotal * 0.02) : 0.00;
        double netBill = subtotal + lateSurcharge - onlineRebate;

        return new BillBreakdown(energyCharge, fixedCharge, lateSurcharge, onlineRebate, Math.round(netBill * 100.0) / 100.0);
    }

    /**
     * Demonstrates primitive casting issues (int division, integer overflow, double truncation).
     */
    public static void demonstratePrimitivePitfalls() {
        System.out.println("--- 3. Primitive Type Casting Pitfalls & Mitigations (Task 5) ---");

        // Pitfall 1: Integer Division Truncation
        int totalUnits = 350;
        int billingDays = 30;
        double flawedDailyAvg = totalUnits / billingDays; // Evaluates integer division first (11.0)
        double correctedDailyAvg = (double) totalUnits / billingDays; // Proper cast (11.666...)
        System.out.printf("1. Integer Division Pitfall: 350 / 30 -> Flawed: %.2f | Corrected with cast: %.2f%n",
            flawedDailyAvg, correctedDailyAvg);

        // Pitfall 2: Integer Arithmetic Overflow
        int highTensionReadingA = 2_000_000_000;
        int highTensionReadingB = 250_000_000;
        int overflowedSum = highTensionReadingA + highTensionReadingB; // Wraps into negative values!
        long safeSum = (long) highTensionReadingA + highTensionReadingB; // Promoted to 64-bit signed long
        System.out.printf("2. Integer Overflow Pitfall: 2,000,000,000 + 250,000,000 -> Overflowed int: %d | Safe long: %d%n",
            overflowedSum, safeSum);

        // Pitfall 3: Floating-Point Truncation during Double-to-Int Casting
        double accurateRupees = 499.98;
        int truncatedPaisa = (int) accurateRupees; // Unintended data loss (499 instead of 500)
        long roundedPaisa = Math.round(accurateRupees);
        System.out.printf("3. Double to Int Truncation: 499.98 -> Truncated int: %d | Math.round: %d%n",
            truncatedPaisa, roundedPaisa);
    }
}
