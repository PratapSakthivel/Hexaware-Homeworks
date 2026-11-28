package com.hexaware.insurance;

public abstract class Policy {
    private String policyNumber;
    private String policyHolderName;
    private PolicyStatus status;
    private double baseAmount;

    public Policy(String policyNumber, String policyHolderName, PolicyStatus status, double baseAmount) {
        setPolicyNumber(policyNumber);
        this.policyHolderName = policyHolderName;
        this.status = status;
        this.baseAmount = baseAmount;
    }

    public String getPolicyNumber() { return policyNumber; }

    public void setPolicyNumber(String policyNumber) {
        if (policyNumber == null || !policyNumber.matches("POL-\\d{4,8}")) {
            throw new IllegalArgumentException("Invalid policy number format. Must match POL-XXXX.");
        }
        this.policyNumber = policyNumber;
    }

    public String getPolicyHolderName() { return policyHolderName; }
    public PolicyStatus getStatus() { return status; }
    public void setStatus(PolicyStatus status) { this.status = status; }
    public double getBaseAmount() { return baseAmount; }

    public abstract double calculatePremium();
    public abstract String getPolicyType();
}
