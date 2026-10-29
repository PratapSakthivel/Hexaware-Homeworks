# Set 3 – Hospital Appointment Desk

Clinical Operations, Triage Sorting, Roster Management, and Doctor Shift Scheduling Suite.

## Project Structure
```
Set3_HospitalAppointmentDesk/
├── COMPLEXITY_AND_RATIONALE.md   # Complexity table, data-structure choices, and typed trace
├── console_output.txt            # Complete captured execution log for all 5 tasks
├── data/
│   ├── patients.csv              # 20,000 patient records
│   └── appointments.csv          # 5,000 daily hospital appointments
├── src/
│   └── com/hexaware/hospital/
│       ├── Main.java             # Master runner executing all 5 clinical tasks
│       ├── model/
│       │   ├── Patient.java      # Patient model (patientId, name, age, phone)
│       │   └── Appointment.java  # Appointment model with multi-key comparison (urgency & arrival)
│       ├── task1/
│       │   └── PatientSearchBenchmark.java # Linear vs Binary search over 20,000 patients
│       ├── task2/
│       │   └── AppointmentSortBenchmark.java# Selection vs Quick sort + typed paper trace
│       ├── task3/
│       │   └── DoubleBookingDetector.java   # Double-booking detection (HashSet vs List Scan)
│       ├── task4/
│       │   ├── CustomQueue.java             # Custom FIFO queue for walk-in token line
│       │   ├── CustomStack.java             # Custom LIFO stack for recent patient charts
│       │   └── TokenLineAndHistoryDemo.java # Clinical workflow simulation
│       ├── task5/
│       │   └── DoctorShiftScheduler.java    # Weighted interval scheduling (DP vs Greedy)
│       └── util/
│           └── HospitalDataGenerator.java   # High-performance CSV generator & loader
├── run.bat                       # One-click Windows CMD build & runner
└── run.ps1                       # One-click PowerShell build & runner
```

## How to Run

### PowerShell:
```powershell
.\run.ps1
```

### Windows CMD:
```cmd
run.bat
```

### Manual:
```powershell
& 'C:\Program Files\Java\jdk-25.0.5.0.3\bin\javac.exe' -d bin -sourcepath src src/com/hexaware/hospital/Main.java
& 'C:\Program Files\Java\jdk-25.0.5.0.3\bin\java.exe' -cp bin com.hexaware.hospital.Main
```
