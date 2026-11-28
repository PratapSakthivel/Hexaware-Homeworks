package com.hexaware.crm;

import java.util.HashSet;
import java.util.Set;

public class CustomerDeduplicationApp {
    public static void main(String[] args) {
        System.out.println("==========================================================================");
        System.out.println("              CRM CUSTOMER MASTER DE-DUPLICATION ENGINE                 ");
        System.out.println("==========================================================================\n");

        // Simulating incoming leads across 3 channels (Web Portal, Mobile App, Store POS)
        Customer[] rawFeed = {
            new Customer("CRM-101", "Arun Sharma", "ARUN.SHARMA@GMAIL.COM", "9876543210"),
            new Customer("CRM-102", "Pooja Hegde", "pooja.h@yahoo.com", "9123456780"),
            new Customer("CRM-103", "Arun S.", "  arun.sharma@gmail.com  ", "9876543210"), // Duplicate of 101
            new Customer("CRM-104", "Vikram Sen", "vikram.sen@outlook.com", "9811223344"),
            new Customer("CRM-105", "P. Hegde", "POOJA.H@YAHOO.COM", "9123456780")          // Duplicate of 102
        };

        System.out.println("Incoming Raw Records Count: " + rawFeed.length);
        Set<Customer> deduplicatedSet = new HashSet<>();
        for (Customer c : rawFeed) {
            boolean added = deduplicatedSet.add(c);
            System.out.printf("Processing: %-30s | Deduplication Status: %s%n",
                c.getNormalizedEmail(), added ? "ACCEPTED (New Customer)" : "REJECTED (Duplicate Removed)");
        }

        System.out.println("\n--- Unique Master Records in CRM HashSet (" + deduplicatedSet.size() + " customers) ---");
        deduplicatedSet.forEach(System.out::println);

        // String Constant Pool Proof (Task 3)
        System.out.println("\n--- String Constant Pool (SCP) == vs equals() Proof ---");
        String s1 = "HexawareCRM";
        String s2 = "HexawareCRM";
        String s3 = new String("HexawareCRM");
        System.out.println("Literal vs Literal (s1 == s2): " + (s1 == s2) + " [Both refer to same SCP instance]");
        System.out.println("Literal vs new String (s1 == s3): " + (s1 == s3) + " [s3 is separate Heap object]");
        System.out.println("Content Equality (s1.equals(s3)): " + s1.equals(s3) + " [Character sequences identical]");
    }
}
