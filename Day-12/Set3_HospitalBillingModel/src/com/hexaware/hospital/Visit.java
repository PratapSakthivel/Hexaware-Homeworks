package com.hexaware.hospital;

public abstract class Visit {
    private final String visitId; // Immutable field
    private final Patient patient;
    private final Doctor doctor;
    private final VisitType visitType;

    public Visit(String visitId, Patient patient, Doctor doctor, VisitType visitType) {
        if (visitId == null || !visitId.startsWith("VIS-")) {
            throw new IllegalArgumentException("Invalid Visit ID. Must start with VIS-");
        }
        this.visitId = visitId;
        this.patient = patient;
        this.doctor = doctor;
        this.visitType = visitType;
    }

    public String getVisitId() { return visitId; }
    public Patient getPatient() { return patient; }
    public Doctor getDoctor() { return doctor; }
    public VisitType getVisitType() { return visitType; }

    // Method Overriding target
    public abstract double calculateBill();

    // Method Overloading variant: Bill calculation with insurance copay discount
    public double calculateBill(double insuranceCopayPercentage) {
        double rawBill = calculateBill();
        return rawBill - (rawBill * (insuranceCopayPercentage / 100.0));
    }
}
