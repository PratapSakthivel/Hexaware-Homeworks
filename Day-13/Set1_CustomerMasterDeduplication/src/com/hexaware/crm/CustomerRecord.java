package com.hexaware.crm;

// Task 2: Equivalent value object as a Java Record
public record CustomerRecord(String customerId, String fullName, String normalizedEmail, String maskedPhone) implements Auditable {
    public CustomerRecord {
        if (normalizedEmail != null) normalizedEmail = normalizedEmail.trim().toLowerCase();
    }
}
