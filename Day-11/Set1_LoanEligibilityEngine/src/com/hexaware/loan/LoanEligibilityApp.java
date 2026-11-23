package com.hexaware.loan;

import java.util.ArrayList;
import java.util.List;

/**
 * Day 11 - Set 1: Loan Eligibility Engine (JDK 25 LTS)
 * Demonstrates local variable type inference (var), 6-rule validation ladder,
 * enhanced switch expressions with pattern matching, loop control (break/continue),
 * formatted decision tables (printf), and edge case handling.
 */
public class LoanEligibilityApp {

    public record Applicant(
        String applicantId,
        String name,
        int age,
        double monthlyIncome,
        double requestedLoanAmount,
        double proposedMonthlyEmi,
        int creditScore,
        String employmentType,
        int existingActiveLoans
    ) {}

    public record DecisionResult(
        String applicantId,
        String name,
        String status,
        String loanProduct,
        double interestRate,
        String rationale
    ) {}

    public static void main(String[] args) {
        System.out.println("=========================================================================================");
        System.out.println("                  RETAIL BANKING LOAN PRE-SCREENING ELIGIBILITY ENGINE                  ");
        System.out.println("=========================================================================================\n");

        var applicants = getSampleApplicants();
        var decisions = new ArrayList<DecisionResult>();

        final int DAILY_APPROVAL_LIMIT = 5;
        int approvedCount = 0;

        for (var app : applicants) {
            // Task 4: Continue on invalid records
            if (app.monthlyIncome() <= 0 || app.age() < 0 || app.creditScore() < 300 || app.creditScore() > 900) {
                decisions.add(new DecisionResult(
                    app.applicantId(), app.name(), "REJECTED_INVALID", "NONE", 0.0,
                    "Edge Case Validation: Negative age, zero income, or credit score out of range [300-900]"
                ));
                continue;
            }

            // Task 4: Break when daily approval limit is reached
            if (approvedCount >= DAILY_APPROVAL_LIMIT) {
                System.out.println("[NOTICE] Daily approval quota of " + DAILY_APPROVAL_LIMIT + " loans reached. Halting batch processing.\n");
                break;
            }

            // Evaluate Loan Eligibility Rules (Task 2 & 3)
            var decision = evaluateApplicant(app);
            if ("APPROVED".equals(decision.status())) {
                approvedCount++;
            }
            decisions.add(decision);
        }

        // Task 5: Print formatted decision table using printf
        printDecisionTable(decisions);
    }

    /**
     * Evaluates the 6 business rules using if-else ladders and nested conditions.
     */
    public static DecisionResult evaluateApplicant(Applicant app) {
        // Rule 1: Age Band (21 - 60)
        if (app.age() < 21 || app.age() > 60) {
            return new DecisionResult(app.applicantId(), app.name(), "REJECTED", "NONE", 0.0, "Age outside acceptable 21-60 band");
        }

        // Rule 2: Income-to-EMI Ratio (EMI must not exceed 50% of monthly income)
        double emiRatio = (app.proposedMonthlyEmi() / app.monthlyIncome()) * 100.0;
        if (emiRatio > 50.0) {
            return new DecisionResult(app.applicantId(), app.name(), "REJECTED", "NONE", 0.0, String.format("EMI ratio %.1f%% exceeds 50%% ceiling", emiRatio));
        }

        // Rule 3: Existing Active Loan Limit (Max 3 loans allowed)
        if (app.existingActiveLoans() >= 3) {
            return new DecisionResult(app.applicantId(), app.name(), "REJECTED", "NONE", 0.0, "Applicant has reached active loans threshold (>= 3)");
        }

        // Rule 4: Employment Type Eligibility
        if (!"SALARIED".equalsIgnoreCase(app.employmentType()) && !"SELF_EMPLOYED".equalsIgnoreCase(app.employmentType())) {
            return new DecisionResult(app.applicantId(), app.name(), "REJECTED", "NONE", 0.0, "Unrecognized or ineligible employment type");
        }

        // Task 3: Enhanced Switch Expression with Pattern Matching & Range Evaluation
        // Maps credit score bands to interest rate and loan product
        return switch (app.creditScore()) {
            case int s when s >= 780 -> new DecisionResult(
                app.applicantId(), app.name(), "APPROVED", "PRIME_SUPER_EXPRESS", 8.25,
                "Excellent credit profile; eligible for lowest risk rate."
            );
            case int s when s >= 720 -> new DecisionResult(
                app.applicantId(), app.name(), "APPROVED", "STANDARD_HOME_SECURE", 9.10,
                "Strong credit profile; standard tier approval."
            );
            case int s when s >= 650 -> new DecisionResult(
                app.applicantId(), app.name(), "APPROVED", "SUBPRIME_CREDIT_BUILDER", 11.50,
                "Fair credit profile; approved with premium rate loading."
            );
            default -> new DecisionResult(
                app.applicantId(), app.name(), "REJECTED", "NONE", 0.0,
                "Credit score below minimum underwriting floor (< 650)."
            );
        };
    }

    private static List<Applicant> getSampleApplicants() {
        return List.of(
            new Applicant("APP-101", "Arun Kumar",     28,  85000.0, 1500000.0, 22000.0, 810, "SALARIED", 1),
            new Applicant("APP-102", "Priya Nair",     34, 120000.0, 2500000.0, 45000.0, 745, "SALARIED", 0),
            new Applicant("APP-103", "Karthik Raja",   19,  40000.0,  500000.0, 12000.0, 700, "SALARIED", 0),  // Age < 21
            new Applicant("APP-104", "Sneha Patel",    42,  90000.0, 3000000.0, 58000.0, 760, "SELF_EMPLOYED", 1), // EMI ratio > 50%
            new Applicant("APP-105", "Deepak Verma",   31,  65000.0,  800000.0, 18000.0, 675, "SALARIED", 1),
            new Applicant("APP-106", "Rohan Gupta",    65, 150000.0, 1000000.0, 25000.0, 820, "SALARIED", 0),  // Age > 60
            new Applicant("APP-107", "Meera Joshi",    29,      0.0,  500000.0, 10000.0, 710, "UNEMPLOYED", 0), // Zero income (Edge case)
            new Applicant("APP-108", "Vikram Batra",   38, 110000.0, 1800000.0, 28000.0, 610, "SALARIED", 0),  // Score < 650
            new Applicant("APP-109", "Ananya Roy",     27,  95000.0, 1200000.0, 21000.0, 790, "SALARIED", 4),  // Loans >= 3
            new Applicant("APP-110", "Suresh Raina",   33,  78000.0, 1400000.0, 24000.0, 730, "SALARIED", 1)
        );
    }

    private static void printDecisionTable(List<DecisionResult> decisions) {
        System.out.printf("%-10s | %-16s | %-14s | %-26s | %-8s | %s%n",
            "APP ID", "APPLICANT NAME", "DECISION", "LOAN PRODUCT", "RATE(%)", "UNDERWRITING RATIONALE");
        System.out.println("-------------------------------------------------------------------------------------------------------------------------");

        for (var d : decisions) {
            System.out.printf("%-10s | %-16s | %-14s | %-26s | %-8.2f | %s%n",
                d.applicantId(),
                d.name(),
                d.status(),
                d.loanProduct(),
                d.interestRate(),
                d.rationale()
            );
        }
        System.out.println("-------------------------------------------------------------------------------------------------------------------------");
    }
}
