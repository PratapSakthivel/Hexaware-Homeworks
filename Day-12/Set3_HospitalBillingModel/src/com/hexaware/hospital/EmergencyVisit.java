package com.hexaware.hospital;

public class EmergencyVisit extends Visit {
    private double traumaSurcharge;
    private double emergencyIcuCharge;

    public EmergencyVisit(String visitId, Patient patient, Doctor doctor, double traumaSurcharge, double emergencyIcuCharge) {
        super(visitId, patient, doctor, VisitType.EMERGENCY);
        this.traumaSurcharge = traumaSurcharge;
        this.emergencyIcuCharge = emergencyIcuCharge;
    }

    @Override
    public double calculateBill() {
        return getDoctor().getConsultationFee() + traumaSurcharge + emergencyIcuCharge;
    }
}
