package com.hexaware.invoice;

public class CorporateInvoice extends Invoice {
    private final String gstin;
    private final String purchaseOrderNumber;

    public CorporateInvoice(String customerName, String gstin, String purchaseOrderNumber) {
        super(customerName);
        this.gstin = gstin;
        this.purchaseOrderNumber = purchaseOrderNumber;
    }

    public String getGstin() { return gstin; }
    public String getPurchaseOrderNumber() { return purchaseOrderNumber; }
}
