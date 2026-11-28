# Set 3: Hospital Billing Model – Inheritance Pitfall Analysis & Class Diagram

## 1. Class Diagram (Mermaid)

```mermaid
classDiagram
    class Visit {
        <<abstract>>
        -final String visitId
        -Patient patient
        -Doctor doctor
        -VisitType visitType
        +calculateBill()* double
        +calculateBill(double copay) double
    }
    class VisitType {
        <<enumeration>>
        OUTPATIENT
        INPATIENT
        EMERGENCY
    }
    class Patient {
        -final String patientId
        -final String name
        -final int age
    }
    class Doctor {
        -final String doctorId
        -final String name
        -final String department
        -final double consultationFee
    }
    class OutPatientVisit {
        -double diagnosticsCharges
        +calculateBill() double
    }
    class InPatientVisit {
        -int daysAdmitted
        -double roomChargePerDay
        -double nursingCharges
        +calculateBill() double
    }
    class EmergencyVisit {
        -double traumaSurcharge
        -double emergencyIcuCharge
        +calculateBill() double
    }

    Visit <|-- OutPatientVisit
    Visit <|-- InPatientVisit
    Visit <|-- EmergencyVisit
    Visit --> Patient : has-a
    Visit --> Doctor : has-a
    Visit --> VisitType
```

## 2. Inheritance Pitfall: Why `Doctor extends Patient` or `Patient extends Visit` is Flawed
- **The Misuse:** An amateur design might declare `class Patient extends Visit` to avoid writing composition getters.
- **Why It Breaks OO Principles:**
  1. A `Patient` is NOT a `Visit` (Liskov Substitution Principle violated).
  2. A patient can have 10 distinct visits over a year. Inheritance forces a 1-to-1 rigid compile-time bind.
  3. Patients have personal attributes (name, medical history, blood group), whereas visits model an episodic clinical billing transaction.
- **Composition Alternative:** `Visit` composes `Patient` (`private final Patient patient`).
