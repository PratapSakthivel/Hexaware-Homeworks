package com.hexaware.inventory;

import java.util.*;

public class RetailInventoryApp {
    public static void main(String[] args) {
        System.out.println("==========================================================================");
        System.out.println("               RETAIL INVENTORY MANAGER & COLLECTION SUITE               ");
        System.out.println("==========================================================================\n");

        // Task 1: HashMap keyed by SKU
        Map<String, Product> inventory = new HashMap<>();
        inventory.put("SKU-101", new Product("SKU-101", "Gaming Laptop 16GB", "Electronics", 15));
        inventory.put("SKU-102", new Product("SKU-102", "Wireless Mouse", "Electronics", 4));
        inventory.put("SKU-103", new Product("SKU-103", "Air Fryer 4L", "Appliances", 3));
        inventory.put("SKU-104", new Product("SKU-104", "Microwave 28L", "Appliances", 18));
        inventory.put("SKU-105", new Product("SKU-105", "Mechanical Keyboard", "Electronics", 25));

        // Task 3: ArrayDeque as recent activity log (last 10 movements)
        Deque<String> activityLog = new ArrayDeque<>();
        activityLog.push("ADD: SKU-101 (+15)");
        activityLog.push("UPDATE: SKU-102 (-2 sold)");
        activityLog.push("RESTOCK: SKU-103 (+10)");

        System.out.println("--- Low Stock Alert (< 5 units) ---");
        inventory.values().stream()
            .filter(p -> p.getStockQuantity() < 5)
            .forEach(p -> System.out.println("ALERT REORDER: " + p));

        // Task 2: Sorting using Comparable and Comparator
        List<Product> productList = new ArrayList<>(inventory.values());
        Collections.sort(productList); // Natural Comparable order
        System.out.println("\n--- Sorted by Natural Comparable (Category ASC, Stock DESC, Name ASC) ---");
        productList.forEach(System.out::println);

        // Task 5: Autoboxing, Integer Cache [-128 to 127] trap
        System.out.println("\n--- Autoboxing & Integer Cache == vs equals() Trap ---");
        Integer a = 127;
        Integer b = 127;
        System.out.println("Integer Cache Range (127 == 127): " + (a == b) + " [Cached instances identical]");

        Integer x = 128;
        Integer y = 128;
        System.out.println("Beyond Cache Range (128 == 128): " + (x == y) + " [TRAP! Separate Heap objects]");
        System.out.println("Proper Value Equality (128.equals(128)): " + x.equals(y));
    }
}
