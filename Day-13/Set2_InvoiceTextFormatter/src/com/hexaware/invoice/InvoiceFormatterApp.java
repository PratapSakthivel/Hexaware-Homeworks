package com.hexaware.invoice;

public class InvoiceFormatterApp {
    public static void main(String[] args) {
        System.out.println("==========================================================================");
        System.out.println("           ENTERPRISE INVOICE TEXT FORMATTER & STRING BENCHMARK          ");
        System.out.println("==========================================================================\n");

        // Task 1: Benchmark String concatenation vs StringBuilder vs StringBuffer across 1,000 items
        benchmarkStringPerformance();

        // Task 2 & 5: Format using Text Blocks, String.format & Pattern Matching for instanceof
        CorporateInvoice corp = new CorporateInvoice("Reliance Retail Ltd", "27AAACR1234M1Z5", "PO-2026-9901");
        corp.addLine(new InvoiceLine("SKU-101", "Enterprise Server Blade", 2, 125000.00));
        corp.addLine(new InvoiceLine("SKU-102", "Rackmount PDU 32A", 4, 18500.00));
        corp.addLine(new InvoiceLine("SKU-103", "Cat6A Patch Cord 2m", 50, 450.00));

        RetailInvoice ret = new RetailInvoice("Aditya Kashyap", "LOYAL-GOLD-4412");
        ret.addLine(new InvoiceLine("SKU-501", "Wireless Ergonomic Mouse", 1, 2499.00));
        ret.addLine(new InvoiceLine("SKU-502", "Mechanical Keyboard RGB", 1, 4999.00));

        printInvoiceDocument(corp);
        printInvoiceDocument(ret);
    }

    // Task 5: instanceof with pattern matching
    public static void printInvoiceDocument(Invoice inv) {
        String headerExtra = switch (inv) {
            case CorporateInvoice c -> String.format("Type: CORPORATE | GSTIN: %s | PO: %s", c.getGstin(), c.getPurchaseOrderNumber());
            case RetailInvoice r    -> String.format("Type: RETAIL    | Loyalty ID: %s", r.getLoyaltyCardNumber());
            default                 -> "Type: GENERAL";
        };

        // Task 2: Text Block Template
        String template = """
            +-------------------------------------------------------------------------------+
            | OFFICIAL TAX INVOICE : %-15s                            |
            | Customer: %-25s                           |
            | %-77s |
            +-------------------------------------------------------------------------------+
            | ITEM CODE | DESCRIPTION                 | QTY | UNIT PRICE (?) | TOTAL (?)    |
            +-------------------------------------------------------------------------------+
            """;

        System.out.printf(template, inv.getInvoiceNumber(), inv.getCustomerName(), headerExtra);
        for (InvoiceLine line : inv.getLines()) {
            System.out.printf("| %-9s | %-27s | %3d | %14.2f | %12.2f |%n",
                line.getItemCode(), line.getDescription(), line.getQuantity(), line.getUnitPrice(), line.getLineTotal());
        }
        System.out.println("+-------------------------------------------------------------------------------+");
        System.out.printf("| SUBTOTAL:                                                  | %12.2f |%n", inv.getSubtotal());
        System.out.printf("| GST (18.0%%):                                              | %12.2f |%n", inv.getSubtotal() * 0.18);
        System.out.printf("| TOTAL PAYABLE AMOUNT:                                      | %12.2f |%n", inv.getTotalWithTax());
        System.out.println("+-------------------------------------------------------------------------------+\n");
    }

    private static void benchmarkStringPerformance() {
        System.out.println("--- 1. String Concatenation vs StringBuilder vs StringBuffer Benchmark (1,000 Items) ---");
        int count = 1000;

        // String Concatenation (+)
        long start = System.nanoTime();
        String str = "";
        for (int i = 0; i < count; i++) {
            str += "Item#" + i + ";";
        }
        long timeString = System.nanoTime() - start;

        // StringBuilder (Unsynchronized)
        start = System.nanoTime();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < count; i++) {
            sb.append("Item#").append(i).append(";");
        }
        long timeStringBuilder = System.nanoTime() - start;

        // StringBuffer (Thread-Safe Synchronized)
        start = System.nanoTime();
        StringBuffer sbuf = new StringBuffer();
        for (int i = 0; i < count; i++) {
            sbuf.append("Item#").append(i).append(";");
        }
        long timeStringBuffer = System.nanoTime() - start;

        System.out.printf("1. String Concatenation (+)  : %,12d ns (~%.2f ms)%n", timeString, timeString / 1_000_000.0);
        System.out.printf("2. StringBuilder (Optimized) : %,12d ns (~%.2f ms)%n", timeStringBuilder, timeStringBuilder / 1_000_000.0);
        System.out.printf("3. StringBuffer (Thread-Safe): %,12d ns (~%.2f ms)%n", timeStringBuffer, timeStringBuffer / 1_000_000.0);
        System.out.printf("Verdict: StringBuilder is ~%.1fx faster than immutable String concatenation in loops!%n%n", (double) timeString / timeStringBuilder);
    }
}
