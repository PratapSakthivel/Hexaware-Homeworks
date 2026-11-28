# Set 1: Order Validation Rules – Null Handling Transformation Note

## 1. Before: Risky Null Returns
```java
Order o = findOrderById("ORD-999");
double amt = o.amount(); // Throws NullPointerException at runtime if order not found!
```

## 2. After: Modern Java 8 Optional Pipeline
```java
double amt = findOrderById(orders, "ORD-999")
    .map(Order::amount)
    .orElse(0.0); // Completely immune to NPE!
```

## 3. Effective Final Capture in Lambdas
Local variables captured inside lambdas or anonymous inner classes must be `final` or `effectively final` (never reassigned after initialization).
This ensures thread safety and memory model determinism.
