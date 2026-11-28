package com.hexaware.hospital;

public class InPatientVisit extends Visit {
    private int daysAdmitted;
    private double roomChargePerDay;
    private double nursingCharges;

    public InPatientVisit(String visitId, Patient patient, Doctor doctor, int daysAdmitted, double roomChargePerDay, double nursingCharges) {
        super(visitId, patient, doctor, VisitType.INPATIENT);
        this.daysAdmitted = daysAdmitted;
        this.roomChargePerDay = roomChargePerDay;
        this.nursingCharges = nursingCharges;
    }

    @Override
    public double calculateBill() {
        return getDoctor().getConsultationFee() + (daysAdmitted * roomChargePerDay) + nursingCharges;
    }
}
