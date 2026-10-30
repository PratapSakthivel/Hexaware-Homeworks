package com.hexaware.hospital.model;

/**
 * Represents a patient record in the hospital repository.
 */
public class Patient implements Comparable<Patient> {
    private final int patientId;
    private final String name;
    private final int age;
    private final String contactNumber;

    public Patient(int patientId, String name, int age, String contactNumber) {
        this.patientId = patientId;
        this.name = name;
        this.age = age;
        this.contactNumber = contactNumber;
    }

    public int getPatientId() {
        return patientId;
    }

    public String getName() {
        return name;
    }

    public int getAge() {
        return age;
    }

    public String getContactNumber() {
        return contactNumber;
    }

    @Override
    public int compareTo(Patient o) {
        return Integer.compare(this.patientId, o.patientId);
    }

    @Override
    public String toString() {
        return String.format("Patient[ID=%d, Name='%s', Age=%d, Phone='%s']",
                patientId, name, age, contactNumber);
    }
}
