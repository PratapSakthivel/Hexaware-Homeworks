package com.hexaware.insurance;

public class MotorPolicy extends Policy {
    private String vehicleNumber;
    private int vehicleAgeYears;

    public MotorPolicy(String policyNumber, String policyHolderName, PolicyStatus status, double vehicleValue, String vehicleNumber, int vehicleAgeYears) {
        super(policyNumber, policyHolderName, status, vehicleValue);
        this.vehicleNumber = vehicleNumber;
        this.vehicleAgeYears = vehicleAgeYears;
    }

    @Override
    public double calculatePremium() {
        double rate = (vehicleAgeYears > 5) ? 0.05 : 0.035;
        return getBaseAmount() * rate + 1500.0; // Base rate + third party fixed fee
    }

    @Override
    public String getPolicyType() { return "MOTOR (" + vehicleNumber + ")"; }
}
