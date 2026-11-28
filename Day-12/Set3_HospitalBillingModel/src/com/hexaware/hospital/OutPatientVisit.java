package com.hexaware.hospital;

public class OutPatientVisit extends Visit {
    private double diagnosticsCharges;

    public OutPatientVisit(String visitId, Patient patient, Doctor doctor, double diagnosticsCharges) {
        super(visitId, patient, doctor, VisitType.OUTPATIENT);
        this.diagnosticsCharges = diagnosticsCharges;
    }

    @Override
    public double calculateBill() {
        return getDoctor().getConsultationFee() + diagnosticsCharges + 150.0; // Registration fee
    }
}
