package com.hexaware.hospital;

public class Doctor {
    private final String doctorId;
    private final String name;
    private final String department;
    private final double consultationFee;

    public Doctor(String doctorId, String name, String department, double consultationFee) {
        this.doctorId = doctorId;
        this.name = name;
        this.department = department;
        this.consultationFee = consultationFee;
    }

    public String getDoctorId() { return doctorId; }
    public String getName() { return name; }
    public String getDepartment() { return department; }
    public double getConsultationFee() { return consultationFee; }
}
