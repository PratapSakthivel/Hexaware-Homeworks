# Set 1: Insurance Policy Hierarchy – Class Diagram & OCP Rationale

## 1. Class Diagram (Mermaid)

```mermaid
classDiagram
    class Policy {
        <<abstract>>
        -String policyNumber
        -String policyHolderName
        -PolicyStatus status
        -double baseAmount
        +calculatePremium()* double
        +getPolicyType()* String
    }
    class PolicyStatus {
        <<enumeration>>
        DRAFT
        ACTIVE
        LAPSED
        CANCELLED
    }
    class MotorPolicy {
        -String vehicleNumber
        -int vehicleAgeYears
        +calculatePremium() double
    }
    class HealthPolicy {
        -int insuredAge
        -boolean hasPreExistingCondition
        +calculatePremium() double
    }
    class TravelPolicy {
        -int tripDurationDays
        -boolean isInternational
        +calculatePremium() double
    }
    class HomePolicy {
        -double propertyAreaSqFt
        +calculatePremium() double
    }

    Policy <|-- MotorPolicy
    Policy <|-- HealthPolicy
    Policy <|-- TravelPolicy
    Policy <|-- HomePolicy
    Policy --> PolicyStatus
```

## 2. Open/Closed Principle (OCP) Explanation
The Open/Closed Principle states that software entities should be open for extension, but closed for modification.
In this solution, when the new business line `HomePolicy` was requested:
- We did not touch or modify `Policy.java`, `MotorPolicy.java`, `HealthPolicy.java`, or `TravelPolicy.java`.
- We extended `Policy` by creating `HomePolicy` implementing `calculatePremium()`.
- The polymorphic reporting loop in `InsuranceHierarchyApp` processed the new policy seamlessly without requiring `instanceof` checks or `if-else` branching.
