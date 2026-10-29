package com.hexaware.hospital.util;

import com.hexaware.hospital.model.Appointment;
import com.hexaware.hospital.model.Patient;

import java.io.*;
import java.time.LocalTime;
import java.util.*;

/**
 * Data Generator and Loader for Hospital Appointments and Patients.
 */
public class HospitalDataGenerator {

    public static final String DEFAULT_PATIENTS_CSV = "data/patients.csv";
    public static final String DEFAULT_APPOINTMENTS_CSV = "data/appointments.csv";

    public static final int TOTAL_PATIENTS = 20_000;
    public static final int TOTAL_APPOINTMENTS = 5_000;

    private static final String[] FIRST_NAMES = {
            "James", "Mary", "John", "Patricia", "Robert", "Jennifer", "Michael", "Linda",
            "William", "Elizabeth", "David", "Barbara", "Richard", "Susan", "Joseph", "Jessica"
    };

    private static final String[] LAST_NAMES = {
            "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
            "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas"
    };

    private static final String[] SLOTS = {
            "08:00-08:30", "08:30-09:00", "09:00-09:30", "09:30-10:00",
            "10:00-10:30", "10:30-11:00", "11:00-11:30", "11:30-12:00",
            "13:00-13:30", "13:30-14:00", "14:00-14:30", "14:30-15:00",
            "15:00-15:30", "15:30-16:00", "16:00-16:30", "16:30-17:00"
    };

    public static void generateDataIfMissing() throws IOException {
        generatePatientsIfMissing(DEFAULT_PATIENTS_CSV, TOTAL_PATIENTS);
        generateAppointmentsIfMissing(DEFAULT_APPOINTMENTS_CSV, TOTAL_APPOINTMENTS);
    }

    public static void generatePatientsIfMissing(String path, int count) throws IOException {
        File file = new File(path);
        if (file.exists() && file.length() > 0) return;
        File parent = file.getParentFile();
        if (parent != null && !parent.exists()) parent.mkdirs();

        System.out.printf("[Hospital Data] Generating %,d patient records...%n", count);
        Random rand = new Random(2026);

        try (BufferedWriter bw = new BufferedWriter(new FileWriter(file))) {
            bw.write("patientId,name,age,contactNumber\n");
            for (int i = 1; i <= count; i++) {
                int id = 500_000 + i; // Sorted patient ID
                String name = FIRST_NAMES[rand.nextInt(FIRST_NAMES.length)] + " " +
                        LAST_NAMES[rand.nextInt(LAST_NAMES.length)];
                int age = 1 + rand.nextInt(95);
                String phone = "+1-555-" + String.format("%04d", 1000 + rand.nextInt(9000));
                bw.write(String.format("%d,%s,%d,%s\n", id, name, age, phone));
            }
        }
        System.out.println("[Hospital Data] Created patients registry.");
    }

    public static void generateAppointmentsIfMissing(String path, int count) throws IOException {
        File file = new File(path);
        if (file.exists() && file.length() > 0) return;
        File parent = file.getParentFile();
        if (parent != null && !parent.exists()) parent.mkdirs();

        System.out.printf("[Hospital Data] Generating %,d appointments with double-bookings...%n", count);
        Random rand = new Random(404);

        try (BufferedWriter bw = new BufferedWriter(new FileWriter(file))) {
            bw.write("appointmentId,patientId,patientName,urgencyLevel,arrivalTime,slotTime,durationMinutes\n");

            // Plan 5 explicit double-booked slots (same patient and slot) for Task 3
            int[] dupBases = {150, 850, 1900, 3200, 4500};
            int[] dupTargets = {155, 853, 1904, 3206, 4502};
            Map<Integer, Appointment> baseApts = new HashMap<>();

            for (int i = 1; i <= count; i++) {
                int aptId = 10_000 + i;
                int patientId;
                String patientName;
                int urgency;
                LocalTime arrivalTime;
                String slotTime;
                int duration;

                int dupIdx = -1;
                for (int d = 0; d < dupTargets.length; d++) {
                    if (dupTargets[d] == i) {
                        dupIdx = d;
                        break;
                    }
                }

                if (dupIdx != -1) {
                    Appointment base = baseApts.get(dupBases[dupIdx]);
                    patientId = base.getPatientId();
                    patientName = base.getPatientName();
                    slotTime = base.getSlotTime(); // Identical slot!
                    urgency = base.getUrgencyLevel();
                    arrivalTime = base.getArrivalTime().plusMinutes(5);
                    duration = base.getDurationMinutes();
                } else {
                    patientId = 500_001 + rand.nextInt(TOTAL_PATIENTS);
                    patientName = FIRST_NAMES[rand.nextInt(FIRST_NAMES.length)] + " " +
                            LAST_NAMES[rand.nextInt(LAST_NAMES.length)];
                    urgency = 1 + rand.nextInt(4); // 1 to 4
                    int hour = 8 + rand.nextInt(9); // 8 AM to 5 PM
                    int min = rand.nextInt(60);
                    arrivalTime = LocalTime.of(hour, min);
                    slotTime = SLOTS[rand.nextInt(SLOTS.length)];
                    duration = 15 + rand.nextInt(4) * 15; // 15, 30, 45, 60 mins
                }

                for (int b : dupBases) {
                    if (b == i) {
                        baseApts.put(i, new Appointment(aptId, patientId, patientName, urgency, arrivalTime, slotTime, duration));
                        break;
                    }
                }

                bw.write(String.format("%d,%d,%s,%d,%s,%s,%d\n",
                        aptId, patientId, patientName, urgency,
                        arrivalTime.format(Appointment.TIME_FMT), slotTime, duration));
            }
        }
        System.out.println("[Hospital Data] Created appointments dataset.");
    }

    public static List<Patient> loadPatients(String path) throws IOException {
        List<Patient> list = new ArrayList<>(TOTAL_PATIENTS);
        try (BufferedReader br = new BufferedReader(new FileReader(path))) {
            String line = br.readLine();
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] p = line.split(",");
                if (p.length >= 4) {
                    list.add(new Patient(Integer.parseInt(p[0].trim()), p[1].trim(),
                            Integer.parseInt(p[2].trim()), p[3].trim()));
                }
            }
        }
        return list;
    }

    public static List<Appointment> loadAppointments(String path) throws IOException {
        List<Appointment> list = new ArrayList<>(TOTAL_APPOINTMENTS);
        try (BufferedReader br = new BufferedReader(new FileReader(path))) {
            String line = br.readLine();
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] p = line.split(",");
                if (p.length >= 7) {
                    list.add(new Appointment(
                            Integer.parseInt(p[0].trim()),
                            Integer.parseInt(p[1].trim()),
                            p[2].trim(),
                            Integer.parseInt(p[3].trim()),
                            LocalTime.parse(p[4].trim(), Appointment.TIME_FMT),
                            p[5].trim(),
                            Integer.parseInt(p[6].trim())
                    ));
                }
            }
        }
        return list;
    }
}
