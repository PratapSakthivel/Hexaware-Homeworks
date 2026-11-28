package com.hexaware.rental;

public class Customer {
    private String customerId;
    private String name;
    private String drivingLicense;

    public Customer(String customerId, String name, String drivingLicense) {
        this.customerId = customerId;
        this.name = name;
        this.drivingLicense = drivingLicense;
    }

    public String getCustomerId() { return customerId; }
    public String getName() { return name; }
    public String getDrivingLicense() { return drivingLicense; }
}
