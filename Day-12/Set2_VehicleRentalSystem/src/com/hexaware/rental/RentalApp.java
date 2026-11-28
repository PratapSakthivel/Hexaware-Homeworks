package com.hexaware.rental;

public class RentalApp {
    public static void main(String[] args) {
        System.out.println("==========================================================================");
        System.out.println("                     ENTERPRISE VEHICLE RENTAL SYSTEM                     ");
        System.out.println("==========================================================================\n");

        Customer c1 = new Customer("CUST-101", "Vikram Rathore", "DL-KA-2015-0012");
        Customer c2 = new Customer("CUST-102", "Ananya Deshmukh", "DL-MH-2019-9941");
        Customer c3 = new Customer("CUST-103", "Sameer Khan", "DL-DL-2018-4421");

        Vehicle sedan = new Car("KA-01-MJ-1004", "Honda City V", 5);
        Vehicle scooter = new Bike("MH-12-PQ-5541", "Yamaha Aerox 155", true);
        Vehicle transportVan = new Van("DL-04-TR-9002", "Tata Winger Maxi", 12.5);

        Rental[] activeRentals = {
            new Rental("RNT-9001", c1, sedan, 4, 1),        // 4 days + 1 day late
            new Rental("RNT-9002", c2, scooter, 3, 0),      // 3 days, on time
            new Rental("RNT-9003", c3, transportVan, 5, 2)  // 5 days + 2 days late
        };

        for (Rental r : activeRentals) {
            double total = r.calculateTotalAmount();
            System.out.printf("Rental ID: %s | Customer: %-15s | Vehicle: %-18s | Days: %d (+%d late) | Total: ?%.2f%n",
                r.getRentalId(), r.getCustomer().getName(), r.getVehicle().getModelName(),
                r.getRentalDays(), r.getOverdueDays(), total);

            if (r.getVehicle() instanceof Insurable ins) {
                System.out.printf("   +-> Insured Policy: %s (Coverage: ?%.2f)%n",
                    ins.getPolicyRegistration(), ins.calculateInsuranceCoverage());
            }
        }
    }
}
