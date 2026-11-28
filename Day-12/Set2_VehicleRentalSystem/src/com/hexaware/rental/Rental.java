package com.hexaware.rental;

// Task 3: Composition (HAS-A Vehicle and HAS-A Customer)
public class Rental {
    private String rentalId;
    private Customer customer;
    private Vehicle vehicle;
    private int rentalDays;
    private int overdueDays;

    public Rental(String rentalId, Customer customer, Vehicle vehicle, int rentalDays, int overdueDays) {
        this.rentalId = rentalId;
        this.customer = customer;
        this.vehicle = vehicle;
        this.rentalDays = rentalDays;
        this.overdueDays = overdueDays;
    }

    public double calculateTotalAmount() {
        double baseCost = rentalDays * vehicle.getDailyRate();
        double lateFee = overdueDays > 0 ? vehicle.calculateLateFee(overdueDays) : 0.0;
        return baseCost + lateFee;
    }

    public String getRentalId() { return rentalId; }
    public Customer getCustomer() { return customer; }
    public Vehicle getVehicle() { return vehicle; }
    public int getRentalDays() { return rentalDays; }
    public int getOverdueDays() { return overdueDays; }
}
