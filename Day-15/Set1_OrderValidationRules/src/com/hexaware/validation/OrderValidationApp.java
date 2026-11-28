package com.hexaware.validation;

import java.time.LocalDate;
import java.util.*;
import java.util.function.*;

public class OrderValidationApp {
    public static void main(String[] args) {
        System.out.println("==========================================================================");
        System.out.println("               E-COMMERCE ORDER VALIDATION RULES (JAVA 8)                 ");
        System.out.println("==========================================================================\n");

        // Task 1: 5 Predicates
        Predicate<Order> isAmountPositive = o -> o.amount() > 0.0;
        Predicate<Order> isValidPincode = o -> o.pincode() != null && o.pincode().matches("\\d{6}");
        Predicate<Order> isStockAvailable = o -> o.stockAvailable() > 0;
        Predicate<Order> isCouponValid = o -> o.couponExpiryDate() == null || !o.couponExpiryDate().isBefore(LocalDate.now());
        Predicate<Order> isPaymentAllowed = o -> List.of("UPI", "CREDIT_CARD", "NET_BANKING").contains(o.paymentMode());

        // Task 2: Combine using and, or, negate
        Predicate<Order> masterValidationRule = isAmountPositive
            .and(isValidPincode)
            .and(isStockAvailable)
            .and(isCouponValid)
            .and(isPaymentAllowed);

        List<Order> orders = List.of(
            new Order("ORD-101", 2500.0, "560001", 5, LocalDate.now().plusDays(10), "UPI"),
            new Order("ORD-102", -50.0,  "400001", 2, LocalDate.now().plusDays(5), "UPI"),       // Invalid amount
            new Order("ORD-103", 1800.0, "9999",   4, LocalDate.now().plusDays(5), "CREDIT_CARD"),// Invalid pin
            new Order("ORD-104", 4500.0, "110001", 0, LocalDate.now().plusDays(2), "UPI"),       // Out of stock
            new Order("ORD-105", 3200.0, "600001", 8, LocalDate.now().minusDays(1), "UPI")      // Expired coupon
        );

        System.out.println("--- Stream Filter Validation Results ---");
        orders.stream()
            .forEach(o -> System.out.printf("Order %s: %s%n", o.orderId(), masterValidationRule.test(o) ? "VALIDATED_OK" : "REJECTED_RULE_VIOLATION"));

        // Task 3: Function, BiFunction, UnaryOperator
        Function<Double, Double> addGst = amt -> amt * 1.18;
        BiFunction<Double, Double, Double> applyDiscount = (amt, disc) -> amt - disc;
        UnaryOperator<Double> roundCents = amt -> Math.round(amt * 100.0) / 100.0;

        double finalPrice = roundCents.apply(addGst.apply(applyDiscount.apply(2500.0, 300.0)));
        System.out.printf("%nFunction Pipeline (?2500 - ?300 disc + 18%% GST) = ?%.2f%n", finalPrice);

        // Task 4: Optional findOrderById with map, orElse, orElseThrow
        Optional<Order> found = findOrderById(orders, "ORD-101");
        String status = found.map(Order::orderId).orElse("ORDER_NOT_FOUND");
        System.out.println("Found Order Status: " + status);
    }

    public static Optional<Order> findOrderById(List<Order> list, String id) {
        return list.stream().filter(o -> o.orderId().equalsIgnoreCase(id)).findFirst();
    }
}
