package com.hexaware.rental;

public enum VehicleType {
    CAR(1800.0), BIKE(450.0), VAN(3200.0);

    private final double dailyRate;
    VehicleType(double dailyRate) { this.dailyRate = dailyRate; }
    public double getDailyRate() { return dailyRate; }
}
