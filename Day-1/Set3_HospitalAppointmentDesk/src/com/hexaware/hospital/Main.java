package com.hexaware.hospital;

import com.hexaware.hospital.model.Appointment;
import com.hexaware.hospital.model.Patient;
import com.hexaware.hospital.task1.PatientSearchBenchmark;
import com.hexaware.hospital.task2.AppointmentSortBenchmark;
import com.hexaware.hospital.task3.DoubleBookingDetector;
import com.hexaware.hospital.task4.TokenLineAndHistoryDemo;
import com.hexaware.hospital.task5.DoctorShiftScheduler;
import com.hexaware.hospital.util.HospitalDataGenerator;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * Master Main entry point for Set 3: Hospital Appointment Desk.
 */
public class Main {

    public static void main(String[] args) {
        PrintStream originalOut = System.out;
        File logFile = new File("console_output.txt");

        try (FileOutputStream fos = new FileOutputStream(logFile)) {

            OutputStream tee = new OutputStream() {
                @Override
                public void write(int b) throws IOException {
                    originalOut.write(b);
                    fos.write(b);
                }

                @Override
                public void write(byte[] b, int off, int len) throws IOException {
                    originalOut.write(b, off, len);
                    fos.write(b, off, len);
                }

                @Override
                public void flush() throws IOException {
                    originalOut.flush();
                    fos.flush();
                }
            };

            PrintStream dualStream = new PrintStream(tee, true, StandardCharsets.UTF_8.name());
            System.setOut(dualStream);

            printBanner();

            System.out.println(">>> STEP 0: INITIALIZING HOSPITAL DATASETS");
            HospitalDataGenerator.generateDataIfMissing();
            List<Patient> patients = HospitalDataGenerator.loadPatients(HospitalDataGenerator.DEFAULT_PATIENTS_CSV);
            List<Appointment> appointments = HospitalDataGenerator.loadAppointments(HospitalDataGenerator.DEFAULT_APPOINTMENTS_CSV);
            System.out.printf("[Hospital Data] Loaded %,d patients and %,d appointments into active memory.%n%n",
                    patients.size(), appointments.size());

            // TASK 1: Patient Search (Linear vs Binary over 20,000 records)
            PatientSearchBenchmark.runBenchmark(patients);

            // TASK 2: Appointment Sorting by Urgency & Arrival (Selection Sort vs Quick Sort)
            AppointmentSortBenchmark.runBenchmark(appointments);

            // TASK 3: Double-Booked Slot Detection (Hash-based vs List Scan)
            DoubleBookingDetector.runDemo(appointments);

            // TASK 4: Walk-in Token Line (Queue) & Recent Patients Viewed (Stack)
            TokenLineAndHistoryDemo.runDemo(patients);

            // TASK 5: Doctor Shift Scheduling (Dynamic Programming vs Greedy)
            DoctorShiftScheduler.runDemo();

            System.out.println("================================================================================");
            System.out.println("   SET 3: ALL TASKS COMPLETED SUCCESSFULLY!");
            System.out.println("   Console output mirrored to: console_output.txt");
            System.out.println("   Complexity and rationale report: COMPLEXITY_AND_RATIONALE.md");
            System.out.println("================================================================================");

        } catch (Exception e) {
            e.printStackTrace(originalOut);
        } finally {
            System.setOut(originalOut);
        }
    }

    private static void printBanner() {
        System.out.println("################################################################################");
        System.out.println("#                 SET 3 – HOSPITAL APPOINTMENT DESK                            #");
        System.out.println("#      Clinical Operations, Triage Sorting & Scheduling Suite                  #");
        System.out.println("################################################################################");
        System.out.println();
    }
}
