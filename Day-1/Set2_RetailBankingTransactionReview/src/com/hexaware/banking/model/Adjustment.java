package com.hexaware.banking.model;

import java.time.LocalDateTime;

/**
 * Encapsulates an account adjustment operation for the 'reverse last adjustment' Stack.
 */
public class Adjustment {
    private final String accountId;
    private final double adjustmentAmount;
    private final String adjustmentType; // e.g. "OVERDRAFT_FEE_WAIVER", "FRAUD_REIMBURSEMENT", "BALANCE_CORRECTION"
    private final LocalDateTime timestamp;

    public Adjustment(String accountId, double adjustmentAmount, String adjustmentType) {
        this.accountId = accountId;
        this.adjustmentAmount = adjustmentAmount;
        this.adjustmentType = adjustmentType;
        this.timestamp = LocalDateTime.now();
    }

    public String getAccountId() {
        return accountId;
    }

    public double getAdjustmentAmount() {
        return adjustmentAmount;
    }

    public String getAdjustmentType() {
        return adjustmentType;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    @Override
    public String toString() {
        return String.format("Adjustment[Acc=%s, Amt=$%.2f, Type=%s, Time=%s]",
                accountId, adjustmentAmount, adjustmentType, timestamp.format(Transaction.FORMATTER));
    }
}
