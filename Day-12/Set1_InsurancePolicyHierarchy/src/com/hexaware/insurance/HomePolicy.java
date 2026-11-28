package com.hexaware.insurance;

// Task 5: Demonstrating Open/Closed Principle (Added without modifying existing Policy hierarchy classes)
public class HomePolicy extends Policy {
    private double propertyAreaSqFt;

    public HomePolicy(String policyNumber, String policyHolderName, PolicyStatus status, double structureValue, double propertyAreaSqFt) {
        super(policyNumber, policyHolderName, status, structureValue);
        this.propertyAreaSqFt = propertyAreaSqFt;
    }

    @Override
    public double calculatePremium() {
        return (getBaseAmount() * 0.002) + (propertyAreaSqFt * 1.5);
    }

    @Override
    public String getPolicyType() { return "HOME (" + propertyAreaSqFt + " sqft)"; }
}
