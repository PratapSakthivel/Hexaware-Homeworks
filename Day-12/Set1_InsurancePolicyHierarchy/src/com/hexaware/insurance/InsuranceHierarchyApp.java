package com.hexaware.insurance;

public class InsuranceHierarchyApp {
    public static void main(String[] args) {
        System.out.println("==========================================================================");
        System.out.println("            INSURANCE POLICY HIERARCHY - POLYMORPHIC PREMIUM DESK        ");
        System.out.println("==========================================================================\n");

        // Task 3: 8 Policies in an array evaluated via runtime polymorphism
        Policy[] portfolio = new Policy[]{
            new MotorPolicy("POL-1001", "Arun Kumar", PolicyStatus.ACTIVE, 850000.0, "KA-01-MJ-2022", 3),
            new MotorPolicy("POL-1002", "Pooja Verma", PolicyStatus.ACTIVE, 1200000.0, "MH-02-AB-1999", 7),
            new HealthPolicy("POL-1003", "Dr. S. Nair", PolicyStatus.ACTIVE, 1000000.0, 52, true),
            new HealthPolicy("POL-1004", "Kavita Rao", PolicyStatus.ACTIVE, 500000.0, 28, false),
            new TravelPolicy("POL-1005", "Rohan Mehta", PolicyStatus.ACTIVE, 200000.0, 14, true),
            new TravelPolicy("POL-1006", "Sneha Roy", PolicyStatus.ACTIVE, 100000.0, 5, false),
            new HomePolicy("POL-1007", "Vikram Seth", PolicyStatus.ACTIVE, 4500000.0, 1850.0),
            new HealthPolicy("POL-1008", "Deepak Joshi", PolicyStatus.LAPSED, 750000.0, 39, false)
        };

        System.out.printf("%-10s | %-15s | %-10s | %-22s | %-12s | %s%n",
            "POLICY NO", "HOLDER", "STATUS", "PRODUCT TYPE", "SUM ASSURED", "CALCULATED PREMIUM");
        System.out.println("---------------------------------------------------------------------------------------------");

        double totalPortfolioPremium = 0.0;
        for (Policy p : portfolio) {
            double prem = p.calculatePremium();
            totalPortfolioPremium += prem;
            System.out.printf("%-10s | %-15s | %-10s | %-22s | ?%-11.2f | ?%.2f%n",
                p.getPolicyNumber(), p.getPolicyHolderName(), p.getStatus(), p.getPolicyType(), p.getBaseAmount(), prem);
        }
        System.out.println("---------------------------------------------------------------------------------------------");
        System.out.printf("TOTAL ANNUALIZED PORTFOLIO PREMIUM: ?%.2f%n%n", totalPortfolioPremium);

        // Task 4: 2D Array and Jagged Array regional premium collections
        System.out.println("--- 2D & Jagged Array Regional Premium Collections (Task 4) ---");
        // 2D Array: 3 Regions x 4 Quarters
        double[][] quarterlyRegionalRevenue = {
            {450000.0, 520000.0, 610000.0, 580000.0}, // North
            {380000.0, 410000.0, 460000.0, 500000.0}, // South
            {290000.0, 310000.0, 340000.0, 390000.0}  // West
        };
        String[] regions = {"North", "South", "West"};
        for (int r = 0; r < quarterlyRegionalRevenue.length; r++) {
            double regSum = 0;
            for (double q : quarterlyRegionalRevenue[r]) regSum += q;
            System.out.printf("Region %-6s (4 Uniform Quarters) Total: ?%.2f%n", regions[r], regSum);
        }

        // Jagged Array: Regions with unequal branch counts
        // North: 3 branches, South: 4 branches, West: 2 branches
        double[][] jaggedBranchCollections = {
            {120000.0, 180000.0, 210000.0},
            {90000.0, 140000.0, 110000.0, 160000.0},
            {250000.0, 310000.0}
        };
        System.out.println("\nJagged Array Branch Totals:");
        for (int i = 0; i < jaggedBranchCollections.length; i++) {
            double sum = 0;
            for (int j = 0; j < jaggedBranchCollections[i].length; j++) {
                sum += jaggedBranchCollections[i][j];
            }
            System.out.printf("Region %-6s (%d Branches): Total Collected = ?%.2f%n",
                regions[i], jaggedBranchCollections[i].length, sum);
        }
    }
}
