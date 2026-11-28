package com.hexaware.attendance;

import java.time.LocalDate;
import java.util.*;

public class AttendanceReportApp {
    public static void main(String[] args) {
        System.out.println("==========================================================================");
        System.out.println("             CORPORATE TRAINING ATTENDANCE REPORT GENERATOR              ");
        System.out.println("==========================================================================\n");

        // Task 3: Parsing lines of the form 'L101|Asha|2024-03-01|P' and reporting malformed records
        String[] rawLogs = {
            "L101|Asha Bhosle|2026-11-01|P",
            "L102|Sunil Gavaskar|2026-11-01|P",
            "MALFORMED_LINE_WITHOUT_DELIMITERS",
            "L101|Asha Bhosle|2026-11-02|A",
            "L103|Kapil Dev|INVALID_DATE|P",
            "L102|Sunil Gavaskar|2026-11-02|P"
        };

        Map<Learner, Integer> presenceCount = new HashMap<>();
        int totalSessionDays = 2;

        System.out.println("--- Ingestion & Validation Log ---");
        for (String raw : rawLogs) {
            String[] parts = raw.split("\\|");
            if (parts.length != 4) {
                System.out.println("[REJECTED MALFORMED] " + raw + " -> Expected 4 pipe-delimited fields.");
                continue;
            }
            try {
                LocalDate date = LocalDate.parse(parts[2].trim());
                boolean present = "P".equalsIgnoreCase(parts[3].trim());
                Learner l = new Learner(parts[0].trim(), parts[1].trim());

                if (present) {
                    presenceCount.put(l, presenceCount.getOrDefault(l, 0) + 1);
                } else {
                    presenceCount.putIfAbsent(l, 0);
                }
                System.out.println("[PARSED OK] " + l.getName() + " on " + date + " Present=" + present);
            } catch (Exception ex) {
                System.out.println("[REJECTED DATA ERROR] " + raw + " -> " + ex.getMessage());
            }
        }

        // Task 2: Attendance Text Report using String API (format, repeat, strip, substring, join)
        System.out.println("\n" + "=".repeat(65));
        System.out.println("                     FINAL ATTENDANCE REPORT                     ");
        System.out.println("=".repeat(65));
        System.out.printf("%-10s | %-20s | %-12s | %s%n", "LEARNER ID", "NAME", "ATTENDED", "PERCENTAGE");
        System.out.println("-".repeat(65));

        for (Map.Entry<Learner, Integer> entry : presenceCount.entrySet()) {
            double pct = (entry.getValue() * 100.0) / totalSessionDays;
            System.out.printf("%-10s | %-20s | %2d / %-6d | %6.1f%%%n",
                entry.getKey().getLearnerId(), entry.getKey().getName(), entry.getValue(), totalSessionDays, pct);
        }
        System.out.println("=".repeat(65));
    }
}
