package com.hexaware.invoice;

public class InvoiceLine {
    private final String itemCode;
    private final String description;
    private final int quantity;
    private final double unitPrice;

    public InvoiceLine(String itemCode, String description, int quantity, double unitPrice) {
        this.itemCode = itemCode;
        this.description = description;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }

    public double getLineTotal() { return quantity * unitPrice; }
    public String getItemCode() { return itemCode; }
    public String getDescription() { return description; }
    public int getQuantity() { return quantity; }
    public double getUnitPrice() { return unitPrice; }

    @Override
    public String toString() {
        return String.format("InvoiceLine[code=%s, desc='%s', qty=%d, unitPrice=%.2f, total=%.2f]",
            itemCode, description, quantity, unitPrice, getLineTotal());
    }
}
