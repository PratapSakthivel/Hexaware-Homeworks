package com.hexaware.insurance;

import java.util.List;

/**
 * Day 11 - Set 3: Insurance Premium Bands (JDK 25 LTS)
 * Computes insurance premiums based on BMI classification, smoker status,
 * policy terms, and age bands using enhanced switch expressions with guards (when).
 * Demonstrates operator precedence, enhanced for loop with labeled break,
 * and a comprehensive explanation of JVM Stack vs Heap memory management.
 */
public class PremiumBandsApp {

    public record Applicant(
        String id,
        String name,
        int age,
        double weightKg,
        double heightMeters,
        boolean isSmoker,
        int policyTermYears,
        double baseSumAssured
    ) {}

    public record PolicyQuote(
        String id,
        String name,
        double bmi,
        String bmiCategory,
        double baseRate,
        double loadingPct,
        double finalAnnualPremium,
        String underwritingStatus
    ) {}

    public static void main(String[] args) {
        System.out.println("=========================================================================================");
        System.out.println("                    INSURANCE UNDERWRITING & PREMIUM BANDS ENGINE                        ");
        System.out.println("=========================================================================================\n");

        var applicants = getSampleApplicants();

        System.out.printf("%-8s | %-16s | %-5s | %-12s | %-8s | %-12s | %-14s | %s%n",
            "APP ID", "NAME", "BMI", "CATEGORY", "LOAD %", "BASE RATE", "FINAL PREMIUM", "STATUS");
        System.out.println("-----------------------------------------------------------------------------------------------------------------");

        // Task 4: Process list of 8 applicants using an enhanced for-loop with labeled break
        BATCH_EVALUATION:
        for (var app : applicants) {
            // Severe eligibility guard: Stop batch processing if an applicant fails fundamental criteria
            if (app.age() < 18 || app.age() > 70) {
                System.out.printf("%-8s | %-16s | %-5s | %-12s | %-8s | %-12s | %-14s | %s%n",
                    app.id(), app.name(), "N/A", "INELIGIBLE", "0.0%", "0.00", "0.00",
                    "FAILED: Age " + app.age() + " outside insurable limits (18-70). [LABELED BREAK TRIGGERED]");
                System.out.println("\n[BATCH HALTED] Labeled break invoked. Remaining applications postponed for manual review.");
                break BATCH_EVALUATION;
            }

            var quote = evaluatePolicy(app);
            System.out.printf("%-8s | %-16s | %-5.1f | %-12s | %-7.1f%% | ₹%-11.2f | ₹%-13.2f | %s%n",
                quote.id(), quote.name(), quote.bmi(), quote.bmiCategory(), quote.loadingPct(),
                quote.baseRate(), quote.finalAnnualPremium(), quote.underwritingStatus());
        }
        System.out.println("-----------------------------------------------------------------------------------------------------------------\n");
    }

    /**
     * Evaluates policy quote incorporating BMI, age bands, smoker loadings, and term.
     */
    public static PolicyQuote evaluatePolicy(Applicant app) {
        // Task 1: BMI Calculation and Loading Assignment using nested if
        double bmi = app.weightKg() / (app.heightMeters() * app.heightMeters());
        String bmiCategory;
        double bmiLoadingPct;

        if (bmi < 18.5) {
            bmiCategory = "UNDERWEIGHT";
            bmiLoadingPct = 5.0;
        } else if (bmi <= 24.9) {
            bmiCategory = "NORMAL";
            bmiLoadingPct = 0.0;
        } else if (bmi <= 29.9) {
            bmiCategory = "OVERWEIGHT";
            bmiLoadingPct = 10.0;
        } else {
            bmiCategory = "OBESE";
            bmiLoadingPct = 25.0;
        }

        // Additional smoker loading
        double smokerLoadingPct = app.isSmoker() ? 20.0 : 0.0;
        double totalLoadingPct = bmiLoadingPct + smokerLoadingPct;

        // Task 2: Enhanced Switch Expression with Pattern Matching & Guards (when)
        // Determines base annual premium by age band and policy term
        double basePremiumRate = switch (app.age()) {
            case int age when age < 30 && app.policyTermYears() >= 20 -> 8500.00;
            case int age when age < 30 -> 6500.00;
            case int age when age <= 45 && app.policyTermYears() >= 20 -> 14000.00;
            case int age when age <= 45 -> 11000.00;
            case int age when age <= 60 && app.policyTermYears() >= 15 -> 24000.00;
            case int age when age <= 60 -> 19500.00;
            default -> 35000.00;
        };

        // Task 3: Final Premium Calculation using Arithmetic, Comparison & Logical Operators
        // Operator Precedence Explanation:
        // Expression: basePremiumRate * (1.0 + (totalLoadingPct / 100.0))
        // 1. (totalLoadingPct / 100.0) -> Evaluated first inside innermost parentheses
        // 2. (1.0 + ...)               -> Evaluated second inside outer parentheses
        // 3. basePremiumRate * (...)   -> Multiplicative operation applies the percentage loading
        double finalPremium = basePremiumRate * (1.0 + (totalLoadingPct / 100.0));

        return new PolicyQuote(
            app.id(),
            app.name(),
            bmi,
            bmiCategory,
            basePremiumRate,
            totalLoadingPct,
            Math.round(finalPremium * 100.0) / 100.0,
            "APPROVED_STANDARD"
        );
    }

    private static List<Applicant> getSampleApplicants() {
        return List.of(
            new Applicant("INS-001", "Kiran Desai",    26,  68.0, 1.75, false, 25, 5000000.0), // Normal, young
            new Applicant("INS-002", "Manoj Bajpayee", 42,  84.0, 1.72, true,  20, 7500000.0), // Overweight + Smoker
            new Applicant("INS-003", "Alia Bhatt",     24,  52.0, 1.65, false, 10, 3000000.0), // Normal
            new Applicant("INS-004", "Vikramaditya",   52,  98.0, 1.70, false, 15, 6000000.0), // Obese
            new Applicant("INS-005", "Sunil Chhetri",  38,  70.0, 1.73, false, 20, 10000000.0),// Athletic/Normal
            new Applicant("INS-006", "Geeta Phogat",   31,  63.0, 1.62, false, 25, 4000000.0), // Normal
            new Applicant("INS-007", "Rajnath Singh",  76,  78.0, 1.70, false, 10, 2000000.0), // Over-age (Triggers labeled break!)
            new Applicant("INS-008", "Zoya Akhtar",    29,  56.0, 1.68, true,  15, 5000000.0)  // Should not be evaluated
        );
    }
}
