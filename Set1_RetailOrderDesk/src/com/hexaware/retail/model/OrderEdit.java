package com.hexaware.retail.model;

import java.time.LocalDateTime;

/**
 * Encapsulates an edit operation on an Order to support the 'undo last order edit' feature.
 */
public class OrderEdit {
    private final int orderId;
    private final double oldAmount;
    private final double newAmount;
    private final String editReason;
    private final LocalDateTime timestamp;

    public OrderEdit(int orderId, double oldAmount, double newAmount, String editReason) {
        this.orderId = orderId;
        this.oldAmount = oldAmount;
        this.newAmount = newAmount;
        this.editReason = editReason;
        this.timestamp = LocalDateTime.now();
    }

    public int getOrderId() {
        return orderId;
    }

    public double getOldAmount() {
        return oldAmount;
    }

    public double getNewAmount() {
        return newAmount;
    }

    public String getEditReason() {
        return editReason;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    @Override
    public String toString() {
        return String.format("OrderEdit[ID=%d: $%.2f -> $%.2f | Reason: '%s']",
                orderId, oldAmount, newAmount, editReason);
    }
}
