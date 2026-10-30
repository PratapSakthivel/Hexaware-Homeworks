package com.hexaware.banking.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;

/**
 * Represents a retail banking card transaction.
 */
public class Transaction implements Comparable<Transaction> {
    private final long transactionId;
    private final String accountId;
    private final double amount;
    private final String merchant;
    private final LocalDateTime postingDate;
    private final int originalSequence; // To demonstrate sorting stability

    public static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public Transaction(long transactionId, String accountId, double amount, String merchant,
                       LocalDateTime postingDate, int originalSequence) {
        this.transactionId = transactionId;
        this.accountId = accountId;
        this.amount = amount;
        this.merchant = merchant;
        this.postingDate = postingDate;
        this.originalSequence = originalSequence;
    }

    public long getTransactionId() {
        return transactionId;
    }

    public String getAccountId() {
        return accountId;
    }

    public double getAmount() {
        return amount;
    }

    public String getMerchant() {
        return merchant;
    }

    public LocalDateTime getPostingDate() {
        return postingDate;
    }

    public int getOriginalSequence() {
        return originalSequence;
    }

    @Override
    public int compareTo(Transaction other) {
        return this.postingDate.compareTo(other.postingDate);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Transaction that = (Transaction) o;
        return transactionId == that.transactionId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(transactionId);
    }

    @Override
    public String toString() {
        return String.format("Txn[ID=%d, Acc=%s, Amt=$%.2f, Merch='%s', Date=%s, Seq=%d]",
                transactionId, accountId, amount, merchant, postingDate.format(FORMATTER), originalSequence);
    }
}
