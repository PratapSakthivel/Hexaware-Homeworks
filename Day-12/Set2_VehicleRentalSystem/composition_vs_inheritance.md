# Set 2: Vehicle Rental System – Composition vs Inheritance & SRP Refactoring

## 1. Composition (HAS-A) vs Inheritance (IS-A)
- **Inheritance (`Car IS-A Vehicle`):** Used when the subclass is truly a specialized kind of the parent class, sharing intrinsic attributes (like registration number and daily rate calculation).
- **Composition (`Rental HAS-A Vehicle` and `Rental HAS-A Customer`):**
  - If `Rental` inherited from `Vehicle`, a Rental would permanently be locked into being a specific vehicle type, preventing customer association and reusability.
  - Composition allows a `Rental` to encapsulate a `Vehicle` and `Customer` dynamically at runtime, obeying the principle: *"Favor object composition over class inheritance"*.

## 2. Refactoring the "God Class" (Single Responsibility Principle - SRP)
- **Problem with the God Class:** A monolithic `RentalSystemManager` class originally managed database connection, vehicle state, discount math, invoice printing, and credit card processing.
- **Refactored Architecture:**
  1. `Rental`: Business logic holding transaction data and computing totals.
  2. `Vehicle`: Polymorphic vehicle pricing and late fee calculation.
  3. `RentalInvoicePrinter`: Dedicated presentation layer formatting output.
- **Principle Applied:** Single Responsibility Principle (SRP) — a class should have only one reason to change.
