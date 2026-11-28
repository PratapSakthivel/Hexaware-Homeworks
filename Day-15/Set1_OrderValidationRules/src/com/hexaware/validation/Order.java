package com.hexaware.validation;

import java.time.LocalDate;

public record Order(
    String orderId,
    double amount,
    String pincode,
    int stockAvailable,
    LocalDate couponExpiryDate,
    String paymentMode
) {}
