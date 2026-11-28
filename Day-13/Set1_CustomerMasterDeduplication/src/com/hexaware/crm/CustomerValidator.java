package com.hexaware.crm;

// Task 5: Functional Interface (Single abstract method, eligible for lambdas)
@FunctionalInterface
public interface CustomerValidator {
    boolean validate(Customer customer);
}
