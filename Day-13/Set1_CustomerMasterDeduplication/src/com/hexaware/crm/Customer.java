package com.hexaware.crm;

import java.util.Objects;

// Task 1: Handwritten equals, hashCode, and toString based on normalized email
public class Customer implements Auditable {
    private final String customerId;
    private final String fullName;
    private final String normalizedEmail;
    private final String rawPhone;

    public Customer(String customerId, String fullName, String email, String rawPhone) {
        this.customerId = customerId != null ? customerId.trim() : "";
        this.fullName = fullName != null ? fullName.trim() : "";
        this.normalizedEmail = email != null ? email.trim().toLowerCase() : "";
        this.rawPhone = rawPhone != null ? rawPhone.trim() : "";
    }

    public String getCustomerId() { return customerId; }
    public String getFullName() { return fullName; }
    public String getNormalizedEmail() { return normalizedEmail; }
    public String getRawPhone() { return rawPhone; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Customer customer = (Customer) o;
        return Objects.equals(normalizedEmail, customer.normalizedEmail);
    }

    @Override
    public int hashCode() {
        return Objects.hash(normalizedEmail);
    }

    @Override
    public String toString() {
        return String.format("Customer[id=%s, name='%s', email='%s', maskedPhone='%s']",
            customerId, fullName, normalizedEmail, maskPhoneNumber(rawPhone));
    }

    // Task 3: String cleaning utilities
    public static String maskPhoneNumber(String phone) {
        if (phone == null || phone.length() < 6) return "******";
        int len = phone.length();
        return phone.substring(0, 2) + "*".repeat(len - 4) + phone.substring(len - 2);
    }
}
