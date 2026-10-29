package com.hexaware.hospital.model;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * Represents a patient appointment with urgency rating and scheduled slot.
 */
public class Appointment implements Comparable<Appointment> {
    private final int appointmentId;
    private final int patientId;
    private final String patientName;
    private final int urgencyLevel; // 1 = Critical/Emergency, 2 = Urgent, 3 = Standard, 4 = Routine
    private final LocalTime arrivalTime;
    private final String slotTime; // e.g. "09:00-09:30"
    private final int durationMinutes;

    public static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");

    public Appointment(int appointmentId, int patientId, String patientName,
                       int urgencyLevel, LocalTime arrivalTime, String slotTime, int durationMinutes) {
        this.appointmentId = appointmentId;
        this.patientId = patientId;
        this.patientName = patientName;
        this.urgencyLevel = urgencyLevel;
        this.arrivalTime = arrivalTime;
        this.slotTime = slotTime;
        this.durationMinutes = durationMinutes;
    }

    public int getAppointmentId() {
        return appointmentId;
    }

    public int getPatientId() {
        return patientId;
    }

    public String getPatientName() {
        return patientName;
    }

    public int getUrgencyLevel() {
        return urgencyLevel;
    }

    public LocalTime getArrivalTime() {
        return arrivalTime;
    }

    public String getSlotTime() {
        return slotTime;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }

    public String getUrgencyLabel() {
        switch (urgencyLevel) {
            case 1: return "CRITICAL_L1";
            case 2: return "URGENT_L2";
            case 3: return "STANDARD_L3";
            case 4: return "ROUTINE_L4";
            default: return "LEVEL_" + urgencyLevel;
        }
    }

    /**
     * Primary Sort: Urgency Level ascending (Level 1 first).
     * Secondary Sort: Arrival Time ascending (Earlier arrival first).
     */
    @Override
    public int compareTo(Appointment other) {
        int urgencyComp = Integer.compare(this.urgencyLevel, other.urgencyLevel);
        if (urgencyComp != 0) {
            return urgencyComp;
        }
        return this.arrivalTime.compareTo(other.arrivalTime);
    }

    @Override
    public String toString() {
        return String.format("Apt[ID=%d, PatID=%d, Name='%s', Urgency=%s, Arrival=%s, Slot=%s, Dur=%dmin]",
                appointmentId, patientId, patientName, getUrgencyLabel(),
                arrivalTime.format(TIME_FMT), slotTime, durationMinutes);
    }
}
