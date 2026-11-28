package com.hexaware.rental;

public class Car extends Vehicle implements Insurable {
    private int seatingCapacity;

    public Car(String registrationNumber, String modelName, int seatingCapacity) {
        super(registrationNumber, modelName, VehicleType.CAR);
        this.seatingCapacity = seatingCapacity;
    }

    @Override
    public double calculateLateFee(int daysOverdue) {
        return daysOverdue * (getDailyRate() * 1.5); // 150% penalty
    }

    @Override
    public double calculateInsuranceCoverage() {
        return 500000.0;
    }

    @Override
    public String getPolicyRegistration() {
        return "INS-CAR-" + getRegistrationNumber();
    }
}
