package com.hexaware.inventory;

public class Supplier {
    private final String supplierId;
    private final String companyName;

    public Supplier(String supplierId, String companyName) {
        this.supplierId = supplierId;
        this.companyName = companyName;
    }

    public String getSupplierId() { return supplierId; }
    public String getCompanyName() { return companyName; }

    @Override
    public String toString() {
        return "Supplier[" + supplierId + ": " + companyName + "]";
    }
}
