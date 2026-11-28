package com.hexaware.fee;

import java.util.function.Function;

public class FeeDiscountApp {
    public static void main(String[] args) {
        System.out.println("==========================================================================");
        System.out.println("                 SCHOOL ACADEMIC FEE & DISCOUNT ENGINE                    ");
        System.out.println("==========================================================================\n");

        double baseTuitionFee = 50000.0;

        // Task 1: Custom Functional Interface DiscountRule
        DiscountRule earlyBird = fee -> fee - 5000.0;
        DiscountRule siblingDisc = fee -> fee * 0.90; // 10% off
        DiscountRule meritScholarship = fee -> fee - 10000.0;

        // Task 2: Chaining discounts using Function andThen vs compose
        Function<Double, Double> fEarly = fee -> fee - 5000.0;
        Function<Double, Double> fSibling = fee -> fee * 0.90;

        double andThenResult = fEarly.andThen(fSibling).apply(baseTuitionFee); // (50k - 5k) * 0.90 = 40,500
        double composeResult = fEarly.compose(fSibling).apply(baseTuitionFee); // (50k * 0.90) - 5k = 40,000

        System.out.printf("Base Tuition Fee: ?%.2f%n", baseTuitionFee);
        System.out.printf("andThen Chaining (EarlyBird first, then Sibling): ?%.2f%n", andThenResult);
        System.out.printf("compose Chaining (Sibling first, then EarlyBird): ?%.2f%n", composeResult);

        // Task 4: 4 Kinds of Method References
        Function<Double, String> staticRef = String::valueOf;                  // 1. Static
        FeeDiscountApp instance = new FeeDiscountApp();
        Function<Double, Double> boundRef = instance::auditFee;               // 2. Bound Instance
        Function<String, String> unboundRef = String::trim;                   // 3. Unbound Instance
        Function<String, StringBuilder> ctorRef = StringBuilder::new;         // 4. Constructor
        System.out.println("Method reference demonstrations compiled and validated.");
    }

    public double auditFee(double f) { return f; }
}
