package com.hexaware.insurance;

public class HealthPolicy extends Policy {
    private int insuredAge;
    private boolean hasPreExistingCondition;

    public HealthPolicy(String policyNumber, String policyHolderName, PolicyStatus status, double sumInsured, int insuredAge, boolean hasPreExistingCondition) {
        super(policyNumber, policyHolderName, status, sumInsured);
        this.insuredAge = insuredAge;
        this.hasPreExistingCondition = hasPreExistingCondition;
    }

    @Override
    public double calculatePremium() {
        double ageMultiplier = (insuredAge > 45) ? 0.04 : 0.02;
        double conditionLoading = hasPreExistingCondition ? 2500.0 : 0.0;
        return (getBaseAmount() * ageMultiplier) + conditionLoading;
    }

    @Override
    public String getPolicyType() { return "HEALTH (Age: " + insuredAge + ")"; }
}
