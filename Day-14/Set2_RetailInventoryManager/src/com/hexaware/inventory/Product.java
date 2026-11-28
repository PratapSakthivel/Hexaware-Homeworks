package com.hexaware.inventory;

public class Product implements Comparable<Product> {
    private final String sku;
    private final String name;
    private final String category;
    private int stockQuantity;

    public Product(String sku, String name, String category, int stockQuantity) {
        this.sku = sku;
        this.name = name;
        this.category = category;
        this.stockQuantity = stockQuantity;
    }

    public String getSku() { return sku; }
    public String getName() { return name; }
    public String getCategory() { return category; }
    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }

    // Natural ordering: Category ASC, then Stock DESC, then Name ASC
    @Override
    public int compareTo(Product other) {
        int catComp = this.category.compareTo(other.category);
        if (catComp != 0) return catComp;
        int stockComp = Integer.compare(other.stockQuantity, this.stockQuantity); // DESC
        if (stockComp != 0) return stockComp;
        return this.name.compareTo(other.name);
    }

    @Override
    public String toString() {
        return String.format("Product[sku=%-10s | %-12s | stock=%3d | %s]", sku, category, stockQuantity, name);
    }
}
