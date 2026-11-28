package com.hexaware.rental;

public class Van extends Vehicle implements Insurable {
    private double cargoVolumeCubicMeters;

    public Van(String registrationNumber, String modelName, double cargoVolume) {
        super(registrationNumber, modelName, VehicleType.VAN);
        this.cargoVolumeCubicMeters = cargoVolume;
    }

    @Override
    public double calculateLateFee(int daysOverdue) {
        return daysOverdue * (getDailyRate() * 2.0); // 200% penalty
    }

    @Override
    public double calculateInsuranceCoverage() {
        return 1200000.0;
    }

    @Override
    public String getPolicyRegistration() {
        return "INS-COMM-VAN-" + getRegistrationNumber();
    }
}
