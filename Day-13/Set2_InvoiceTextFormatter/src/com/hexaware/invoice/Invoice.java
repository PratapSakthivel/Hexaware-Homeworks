package com.hexaware.invoice;

import java.util.ArrayList;
import java.util.List;

public abstract class Invoice {
    private static int invoiceSequence = 5000; // Static counter (Task 4)
    public static final double DEFAULT_TAX_RATE = 18.0; // Final constant (Task 4)

    static {
        // Static initializer block (Task 4)
        System.out.println("[BOOTSTRAP] Initialized Invoice Master Sequence Base at: " + invoiceSequence);
    }

    private final String invoiceNumber;
    private final String customerName;
    private final List<InvoiceLine> lines = new ArrayList<>();

    public Invoice(String customerName) {
        this.invoiceNumber = "INV-" + (++invoiceSequence);
        this.customerName = customerName;
    }

    public void addLine(InvoiceLine line) { lines.add(line); }
    public String getInvoiceNumber() { return invoiceNumber; }
    public String getCustomerName() { return customerName; }
    public List<InvoiceLine> getLines() { return lines; }

    public double getSubtotal() {
        return lines.stream().mapToDouble(InvoiceLine::getLineTotal).sum();
    }

    public double getTotalWithTax() {
        double sub = getSubtotal();
        return sub + (sub * (DEFAULT_TAX_RATE / 100.0));
    }
}
