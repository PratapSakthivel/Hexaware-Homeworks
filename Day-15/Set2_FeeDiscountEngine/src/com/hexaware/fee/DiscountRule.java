package com.hexaware.fee;

@FunctionalInterface
public interface DiscountRule {
    double applyDiscount(double fee);

    default DiscountRule combine(DiscountRule nextRule) {
        return fee -> nextRule.applyDiscount(this.applyDiscount(fee));
    }
}
