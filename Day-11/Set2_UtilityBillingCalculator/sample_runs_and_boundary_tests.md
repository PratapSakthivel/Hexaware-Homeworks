# Set 2: Utility Billing Calculator – Boundary Tests & Precedence Documentation

## 1. Boundary Test Values & Tariff Calculations

The tariff model calculates consumption across 4 progressive tiers:
- **Tier 1 (0 – 100 units):** ₹3.00 / unit
- **Tier 2 (101 – 200 units):** ₹4.50 / unit
- **Tier 3 (201 – 400 units):** ₹6.50 / unit
- **Tier 4 (> 400 units):** ₹8.00 / unit
- **Fixed Surcharge:** ₹80.00 (Domestic)
- **Late Surcharge:** +5.0% on subtotal
- **Digital Payment Rebate:** -2.0% on subtotal

### Boundary Test Matrix (Tested on Domestic Category with Late & Online Flags):

| Units Tested | Slab Math Calculation | Energy Charge (₹) | Fixed Charge (₹) | Surcharge (+5%) | Rebate (-2%) | Net Bill Payable (₹) | Boundary Significance |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---|
| **100** | $100 \times 3.00$ | 300.00 | 80.00 | 19.00 | 7.60 | **391.40** | Upper edge of Slab 1 |
| **101** | $300 + (1 \times 4.50)$ | 304.50 | 80.00 | 19.23 | 7.69 | **396.04** | Entry boundary of Slab 2 |
| **200** | $300 + (100 \times 4.50)$ | 750.00 | 80.00 | 41.50 | 16.60 | **854.90** | Upper edge of Slab 2 |
| **201** | $750 + (1 \times 6.50)$ | 756.50 | 80.00 | 41.83 | 16.73 | **861.60** | Entry boundary of Slab 3 |
| **400** | $750 + (200 \times 6.50)$ | 2050.00 | 80.00 | 106.50 | 42.60 | **2193.90** | Upper edge of Slab 3 |
| **401** | $2050 + (1 \times 8.00)$ | 2058.00 | 80.00 | 106.90 | 42.76 | **2202.14** | Entry boundary of Slab 4 |

---

## 2. Operator Precedence Documentation

In `UtilityBillingApp.java`, the bill net calculation is evaluated via:
```java
double netBill = subtotal + lateSurcharge - onlineRebate;
```
Where `lateSurcharge` and `onlineRebate` are derived using:
```java
double lateSurcharge = isLate ? (subtotal * 0.05) : 0.00;
```

### Precedence Table for the Expression:
1. **Parentheses `()` (Highest Priority - 1):** Forces evaluation of `(subtotal * 0.05)` before the conditional choice.
2. **Multiplication `*` (Priority 3):** Evaluates arithmetic floating-point multiplication.
3. **Ternary Operator `? :` (Priority 13):** Selects the calculated surcharge or `0.00` based on the boolean operand.
4. **Binary Addition `+` & Subtraction `-` (Priority 4):** Evaluated from left to right (`subtotal + lateSurcharge - onlineRebate`).
5. **Assignment `=` (Lowest Priority - 14):** Assigns the final scalar value to variable `netBill`.

---

## 3. Sample Execution Output

```text
===============================================================================
                    STATE ELECTRICITY UTILITY BILLING SYSTEM                   
===============================================================================

--- 1. Boundary Test Value Suite ---
Units: 100  | Category: DOMESTIC | Energy: ₹300.00   | Fixed: ₹80.00  | Surcharge: ₹19.00  | Rebate: ₹7.60   | Net: ₹391.40
Units: 101  | Category: DOMESTIC | Energy: ₹304.50   | Fixed: ₹80.00  | Surcharge: ₹19.23  | Rebate: ₹7.69   | Net: ₹396.04
Units: 200  | Category: DOMESTIC | Energy: ₹750.00   | Fixed: ₹80.00  | Surcharge: ₹41.50  | Rebate: ₹16.60  | Net: ₹854.90
Units: 201  | Category: DOMESTIC | Energy: ₹756.50   | Fixed: ₹80.00  | Surcharge: ₹41.83  | Rebate: ₹16.73  | Net: ₹861.60
Units: 400  | Category: DOMESTIC | Energy: ₹2050.00  | Fixed: ₹80.00  | Surcharge: ₹106.50 | Rebate: ₹42.60  | Net: ₹2193.90
Units: 401  | Category: DOMESTIC | Energy: ₹2058.00  | Fixed: ₹80.00  | Surcharge: ₹106.90 | Rebate: ₹42.76  | Net: ₹2202.14

--- 2. 12-Month Simulated Consumption Statement (Commercial Consumer) ---
MONTH  | UNITS USED   | ENERGY CHARGE  | SURCHARGE    | NET PAYABLE 
------------------------------------------------------------------
Jan    | 220          | ₹880.00        | ₹0.00        | ₹1107.40
Feb    | 240          | ₹1010.00       | ₹0.00        | ₹1234.80
Mar    | 310          | ₹1465.00       | ₹0.00        | ₹1680.70
Apr    | 450          | ₹2450.00       | ₹0.00        | ₹2646.00
May    | 520          | ₹3010.00       | ₹0.00        | ₹3194.80
Jun    | 490          | ₹2770.00       | ₹0.00        | ₹2959.60
Jul    | 380          | ₹1920.00       | ₹0.00        | ₹2126.60
Aug    | 290          | ₹1335.00       | ₹0.00        | ₹1553.30
Sep    | 260          | ₹1140.00       | ₹0.00        | ₹1362.20
Oct    | 300          | ₹1400.00       | ₹0.00        | ₹1617.00
Nov    | 275          | ₹1237.50       | ₹0.00        | ₹1457.75
Dec    | 340          | ₹1660.00       | ₹0.00        | ₹1871.80
------------------------------------------------------------------
ANNUAL NET REVENUE COLLECTED: ₹22811.95

--- 3. Primitive Type Casting Pitfalls & Mitigations (Task 5) ---
1. Integer Division Pitfall: 350 / 30 -> Flawed: 11.00 | Corrected with cast: 11.67
2. Integer Overflow Pitfall: 2,000,000,000 + 250,000,000 -> Overflowed int: -2044967296 | Safe long: 2250000000
3. Double to Int Truncation: 499.98 -> Truncated int: 499 | Math.round: 500
```
