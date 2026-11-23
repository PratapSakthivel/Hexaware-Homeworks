# Day 11: Java (JDK 25 LTS) – Introduction and Control Statements

## Overview
This directory contains complete production-grade Java source code, test decision tables, boundary test runs, operator precedence breakdowns, and JVM memory model documentation for **Day 11** of the Hexaware training program.

The assignments leverage modern Java features: local variable type inference (`var`), Java records, enhanced `switch` expressions with pattern matching and guards (`when`), labeled loop jumps, and printf tabular formatting.

---

## Directory Structure

```
Day-11/
├── README.md                                                 # Master overview for Day 11
├── Set1_LoanEligibilityEngine/
│   ├── src/com/hexaware/loan/
│   │   └── LoanEligibilityApp.java                           # 6-rule validation ladder, pattern matching switch & printf table
│   └── decision_table_and_output.md                          # 10-applicant test input matrix & captured execution output
├── Set2_UtilityBillingCalculator/
│   ├── src/com/hexaware/utility/
│   │   └── UtilityBillingApp.java                            # 4-slab tariff, category switch, 12-month loop & casting pitfalls
│   └── sample_runs_and_boundary_tests.md                     # Boundary values (100, 101, 200, 201, 400, 401) & precedence notes
└── Set3_InsurancePremiumBands/
    ├── src/com/hexaware/insurance/
    │   └── PremiumBandsApp.java                              # BMI nested ifs, guarded switch, labeled break & 8-applicant run
    └── memory_model_and_output.md                            # Captured console output & JVM Stack vs Heap memory deep dive
```

---

## Compilation & Execution Instructions (Java 17+ / JDK 25)

```bash
# Set 1 - Loan Eligibility Engine
javac Day-11/Set1_LoanEligibilityEngine/src/com/hexaware/loan/LoanEligibilityApp.java
java -cp Day-11/Set1_LoanEligibilityEngine/src com.hexaware.loan.LoanEligibilityApp

# Set 2 - Utility Billing Calculator
javac Day-11/Set2_UtilityBillingCalculator/src/com/hexaware/utility/UtilityBillingApp.java
java -cp Day-11/Set2_UtilityBillingCalculator/src com.hexaware.utility.UtilityBillingApp

# Set 3 - Insurance Premium Bands
javac Day-11/Set3_InsurancePremiumBands/src/com/hexaware/insurance/PremiumBandsApp.java
java -cp Day-11/Set3_InsurancePremiumBands/src com.hexaware.insurance.PremiumBandsApp
```
