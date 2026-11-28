package com.hexaware.rental;

public class Bike extends Vehicle {
    private boolean includesHelmet;

    public Bike(String registrationNumber, String modelName, boolean includesHelmet) {
        super(registrationNumber, modelName, VehicleType.BIKE);
        this.includesHelmet = includesHelmet;
    }

    @Override
    public double calculateLateFee(int daysOverdue) {
        return daysOverdue * (getDailyRate() * 1.25); // 125% penalty
    }
}
