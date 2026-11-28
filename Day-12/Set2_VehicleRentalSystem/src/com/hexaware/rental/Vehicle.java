package com.hexaware.rental;

public abstract class Vehicle {
    private String registrationNumber;
    private String modelName;
    private VehicleType type;

    public Vehicle(String registrationNumber, String modelName, VehicleType type) {
        setRegistrationNumber(registrationNumber);
        this.modelName = modelName;
        this.type = type;
    }

    public String getRegistrationNumber() { return registrationNumber; }
    public void setRegistrationNumber(String regNo) {
        if (regNo == null || !regNo.matches("[A-Z]{2}-\\d{2}-[A-Z]{1,2}-\\d{4}")) {
            throw new IllegalArgumentException("Invalid registration format. Expected format: KA-01-AB-1234");
        }
        this.registrationNumber = regNo;
    }

    public String getModelName() { return modelName; }
    public VehicleType getType() { return type; }
    public double getDailyRate() { return type.getDailyRate(); }

    public abstract double calculateLateFee(int daysOverdue);
}
