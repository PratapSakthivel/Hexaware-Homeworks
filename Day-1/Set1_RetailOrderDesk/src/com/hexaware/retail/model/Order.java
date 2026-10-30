package com.hexaware.retail.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;

/**
 * Represents a retail order in the order desk system.
 */
public class Order implements Comparable<Order> {
    private final int orderId;
    private final String customerId;
    private double amount;
    private final LocalDateTime createdAt;

    public static final DateTimeFormatter ISO_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    public Order(int orderId, String customerId, double amount, LocalDateTime createdAt) {
        this.orderId = orderId;
        this.customerId = customerId;
        this.amount = amount;
        this.createdAt = createdAt;
    }

    public int getOrderId() {
        return orderId;
    }

    public String getCustomerId() {
        return customerId;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    /**
     * Orders ranked by amount descending (highest amount first).
     * If amounts are equal, sort by orderId ascending for determinism.
     */
    @Override
    public int compareTo(Order other) {
        int amountCompare = Double.compare(other.amount, this.amount);
        if (amountCompare != 0) {
            return amountCompare;
        }
        return Integer.compare(this.orderId, other.orderId);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Order order = (Order) o;
        return orderId == order.orderId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(orderId);
    }

    @Override
    public String toString() {
        return String.format("Order[ID=%d, Cust=%s, Amt=$%.2f, Time=%s]",
                orderId, customerId, amount, createdAt.format(ISO_FORMATTER));
    }
}
