package com.hexaware.insurance;

public class TravelPolicy extends Policy {
    private int tripDurationDays;
    private boolean isInternational;

    public TravelPolicy(String policyNumber, String policyHolderName, PolicyStatus status, double coverageAmount, int tripDurationDays, boolean isInternational) {
        super(policyNumber, policyHolderName, status, coverageAmount);
        this.tripDurationDays = tripDurationDays;
        this.isInternational = isInternational;
    }

    @Override
    public double calculatePremium() {
        double dayRate = isInternational ? 150.0 : 50.0;
        return (tripDurationDays * dayRate) + (getBaseAmount() * 0.005);
    }

    @Override
    public String getPolicyType() { return "TRAVEL (" + (isInternational ? "INTL" : "DOM") + " " + tripDurationDays + "d)"; }
}
