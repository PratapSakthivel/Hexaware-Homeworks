package com.hexaware.hospital;

public class HospitalBillingApp {
    public static void main(String[] args) {
        System.out.println("==========================================================================");
        System.out.println("               HOSPITAL PATIENT BILLING & VISIT INVOICE DESK             ");
        System.out.println("==========================================================================\n");

        Doctor d1 = new Doctor("DOC-01", "Dr. A. Sen", "Cardiology", 1200.0);
        Doctor d2 = new Doctor("DOC-02", "Dr. M. Iyer", "Orthopedics", 900.0);
        Doctor d3 = new Doctor("DOC-03", "Dr. R. Khan", "Emergency Medicine", 1500.0);

        Patient p1 = new Patient("PAT-101", "Ramesh Joshi", 48);
        Patient p2 = new Patient("PAT-102", "Sunita Nair", 34);
        Patient p3 = new Patient("PAT-103", "Amitava Roy", 62);

        Visit[] visits = {
            new OutPatientVisit("VIS-901", p1, d1, 3500.0),
            new InPatientVisit("VIS-902", p2, d2, 4, 2500.0, 1800.0),
            new EmergencyVisit("VIS-903", p3, d3, 5000.0, 8500.0)
        };

        System.out.printf("%-10s | %-15s | %-15s | %-12s | %-12s | %s%n",
            "VISIT ID", "PATIENT", "DOCTOR", "VISIT TYPE", "RAW BILL", "AFTER 20% COPAY");
        System.out.println("-----------------------------------------------------------------------------------------");
        for (Visit v : visits) {
            double raw = v.calculateBill();
            double copayBill = v.calculateBill(20.0); // Overloaded call
            System.out.printf("%-10s | %-15s | %-15s | %-12s | ?%-11.2f | ?%.2f%n",
                v.getVisitId(), v.getPatient().getName(), v.getDoctor().getName(), v.getVisitType(), raw, copayBill);
        }

        // 2D Array: Department-wise Monthly Revenue (3 Depts x 3 Months)
        System.out.println("\n--- Department-wise Monthly Revenue (2D Array) ---");
        double[][] deptMonthlyRevenue = {
            {120000.0, 145000.0, 160000.0}, // Cardiology
            {95000.0,  110000.0, 105000.0}, // Orthopedics
            {210000.0, 230000.0, 245000.0}  // Emergency Medicine
        };
        String[] depts = {"Cardiology", "Orthopedics", "Emergency Medicine"};
        for (int i = 0; i < deptMonthlyRevenue.length; i++) {
            double total = 0;
            for (double rev : deptMonthlyRevenue[i]) total += rev;
            System.out.printf("Department: %-20s | Q1 Total Revenue = ?%.2f%n", depts[i], total);
        }
    }
}
