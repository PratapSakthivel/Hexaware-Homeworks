package com.hexaware.invoice;

public class RetailInvoice extends Invoice {
    private final String loyaltyCardNumber;

    public RetailInvoice(String customerName, String loyaltyCardNumber) {
        super(customerName);
        this.loyaltyCardNumber = loyaltyCardNumber;
    }

    public String getLoyaltyCardNumber() { return loyaltyCardNumber; }
}
