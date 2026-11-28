package com.hexaware.date;

import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.*;

public class InvoiceDueDateApp {
    public static void main(String[] args) {
        System.out.println("==========================================================================");
        System.out.println("            GLOBAL INVOICE DUE-DATE & TIME-ZONE CALCULATOR                ");
        System.out.println("==========================================================================\n");

        LocalDate invoiceDate = LocalDate.of(2026, 10, 15);
        LocalDate dueDate = invoiceDate.plusDays(30);
        LocalDate currentDate = LocalDate.of(2026, 11, 28);

        long overdueDays = ChronoUnit.DAYS.between(dueDate, currentDate);
        System.out.printf("Invoice Date: %s | Net 30 Due Date: %s | Days Overdue: %d days%n%n",
            invoiceDate, dueDate, overdueDays);

        // Task 2: Multi-Timezone conversions (Instant vs ZonedDateTime)
        Instant utcTimestamp = Instant.now();
        ZonedDateTime kolkataTime = utcTimestamp.atZone(ZoneId.of("Asia/Kolkata"));
        ZonedDateTime newYorkTime = utcTimestamp.atZone(ZoneId.of("America/New_York"));

        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss z");
        System.out.println("UTC Instant           : " + utcTimestamp);
        System.out.println("Asia/Kolkata Zoned    : " + kolkataTime.format(fmt));
        System.out.println("America/New_York Zoned: " + newYorkTime.format(fmt));

        // Task 3: Next working day skipping weekends and holidays
        Set<LocalDate> corporateHolidays = Set.of(
            LocalDate.of(2026, 11, 28), // Saturday (also holiday)
            LocalDate.of(2026, 11, 30)  // Monday (Diwali/Festive Holiday)
        );
        LocalDate nextWorking = getNextWorkingDay(LocalDate.of(2026, 11, 27), corporateHolidays);
        System.out.println("\nNext Working Day from Fri 2026-11-27 (skipping holiday Mon): " + nextWorking);
    }

    public static LocalDate getNextWorkingDay(LocalDate from, Set<LocalDate> holidays) {
        LocalDate next = from.plusDays(1);
        while (next.getDayOfWeek() == DayOfWeek.SATURDAY ||
               next.getDayOfWeek() == DayOfWeek.SUNDAY ||
               holidays.contains(next)) {
            next = next.plusDays(1);
        }
        return next;
    }
}
