# Day 3 – Agile and Scrum: Foundations and Backlog Workshop
## Set 3: Hospital Appointment Booking Application

---

## 1. Product Vision & Stakeholder Mapping

### Product Vision Statement
> **"For** patients and outpatient clinic visitors seeking prompt, stress-free medical consultations,  
> **Who** struggle with crowded hospital reception lines, phone hold times, and conflicting doctor availability,  
> **The Hospital Appointment Booking Mobile Application** is a patient-centric scheduling and reminder portal  
> **That** enables instantaneous real-time specialist discovery, appointment booking, self-service rescheduling, and multi-channel SMS/WhatsApp reminders,  
> **Unlike** traditional phone-based booking and rigid paper scheduling systems prone to lost slots and long waiting room delays,  
> **Our product** synchronizes directly with the hospital clinical EMR roster, prevents double-booking, and sends automated pre-consultation reminders."

---

### Stakeholder-to-Scrum Mapping

| Hospital Stakeholder | Primary Interest & Perspective | Mapped Scrum Role | Role Rationale in Scrum Framework |
| :--- | :--- | :--- | :--- |
| **Chief Medical Officer (CMO) / Clinic Ops Director** | Maximizing doctor clinical utilization, reducing patient no-show rates, clinical compliance. | **Product Owner (PO)** | Represents the business and healthcare domain; owns the ROI, prioritizes backlog based on medical operations value. |
| **Agile Coach / Delivery Lead** | Ensuring team self-organization, facilitating sprint ceremonies, removing organizational blockers. | **Scrum Master (SM)** | Coaches team on Scrum principles, shields developers from administrative distraction, facilitates retrospectives. |
| **Lead Mobile Architect, Full-Stack Devs, QA Engineers** | Building native iOS/Android screens, HL7/FHIR EMR integrations, automated regression tests. | **Developers** | Cross-functional technical professionals accountable for designing, developing, testing, and deploying the Done increment. |
| **Outpatient Patients & Hospital Caregivers** | Easy booking for elderly parents, quick reschedule during emergencies, clear reminders. | **Customer / End User** | External stakeholders who provide continuous feedback during sprint reviews and user acceptance testing. |
| **Specialist Physicians & Nursing Supervisors** | Managing daily clinic consultation hours, blocking emergency surgical slots, viewing patient history. | **Internal Stakeholder / User** | Consulted by Product Owner during backlog refinement to ensure physician roster constraints are accurately captured. |

---

## 2. Four Epics & 12 User Stories

### Epic 1: Appointment Booking (BK)
- **STORY-BK-01 (Doctor Discovery by Specialty & Department):**
  *As a* patient experiencing symptoms,  
  *I want to* search and filter doctors by medical department (Cardiology, Orthopedics, Pediatrics), language spoken, and hospital wing,  
  *So that* I can find the right healthcare specialist.
- **STORY-BK-02 (Available Time-Slot Grid Selection):**
  *As an* outpatient visitor,  
  *I want to* view a doctor's real-time consultation calendar and select an open 20-minute appointment slot,  
  *So that* I choose a time that fits my personal schedule.
- **STORY-BK-03 (Patient Details & Medical Reason Intake):**
  *As a* user booking for myself or a dependent child,  
  *I want to* enter basic symptoms and insurance card numbers during booking,  
  *So that* the doctor has initial clinical context before my arrival.
- **STORY-BK-04 (Booking Confirmation & Digital QR Pass):**
  *As a* booked patient,  
  *I want to* receive a booking confirmation pass with a scannable check-in QR code,  
  *So that* I can fast-track hospital kiosk check-in on the appointment date.

### Epic 2: Rescheduling and Cancellation (RC)
- **STORY-RC-05 (Self-Service Appointment Rescheduling):**
  *As a* patient with an unexpected conflict,  
  *I want to* reschedule my existing appointment to a new available date and time up to 2 hours before the visit,  
  *So that* I do not forfeit my consultation fee.
- **STORY-RC-06 (One-Click Cancellation with Reason):**
  *As a* patient whose symptoms resolved or who cannot attend,  
  *I want to* cancel my upcoming appointment with an optional cancellation reason,  
  *So that* the reserved slot is immediately released to other waiting patients.
- **STORY-RC-07 (Automated Waitlist Slot Redistribution):**
  *As a* waiting patient seeking an earlier consultation,  
  *I want to* be notified if a cancelled slot opens up with my preferred doctor,  
  *So that* I can book the earlier cancelled slot.

### Epic 3: Reminders and Notifications (RN)
- **STORY-RN-08 (24-Hour & 2-Hour Push and SMS Alerts):**
  *As a* busy patient,  
  *I want to* receive automated reminders 24 hours and 2 hours prior to my consultation,  
  *So that* I do not forget my scheduled doctor visit.
- **STORY-RN-09 (Pre-Visit Preparation Guidelines):**
  *As a* patient scheduled for specialized testing (e.g., fasting blood glucose or ultrasound),  
  *I want to* receive specific pre-visit instructions (e.g., "Fast for 8 hours prior"),  
  *So that* my clinical tests can be conducted successfully.
- **STORY-RN-10 (Calendar Sync Integration):**
  *As a* mobile user,  
  *I want to* add my confirmed appointment directly to Google Calendar or Apple Calendar with one tap,  
  *So that* I receive my phone's native calendar reminders.

### Epic 4: Doctor Schedule Management (DM)
- **STORY-DM-11 (Doctor Emergency Leave / Slot Blocking):**
  *As a* hospital physician,  
  *I want to* block out clinic hours for emergency surgeries or personal leave,  
  *So that* patients cannot book slots during my absence.
- **STORY-DM-12 (Automated Patient Reassignment / Notification on Doctor Absence):**
  *As a* clinic administrator,  
  *I want to* automatically notify and offer alternate specialist slots to all patients affected when a doctor is called into emergency surgery,  
  *So that* patients receive timely care without disruption.

---

## 3. INVEST Review & Story Rewrites

### Identifying Violations:
1. **Violation 1: Not Independent & Not Testable**  
   - *Bad Story:* "As a user, I want booking, reminders, and cancellations to work together with the hospital database."
   - *Why it fails:* Combines 3 independent domains into one mega-story; cannot be tested or released separately.
2. **Violation 2: Not Estimable & Not Valuable**  
   - *Bad Story:* "As a developer, I want to configure the EMR FHIR messaging bus."
   - *Why it fails:* Written as a technical chore without end-user value; impossible for the Product Owner to prioritize against patient features.

### Rewritten INVEST-Compliant Stories:
- **Rewritten Story #1 (STORY-BK-02: Slot Selection):**  
  *As an outpatient visitor, I want to view a doctor's live calendar and pick an open slot, so that I select an exact consultation time.* (Independent, Small: 3 points, Testable).
- **Rewritten Story #2 (STORY-RC-05: Self-Service Reschedule):**  
  *As a patient, I want to reschedule my appointment to an available date with 1 click, so that I adjust my visit without phone queues.* (Independent, Testable with clear cutoff rules).

---

## 4. Given / When / Then Acceptance Criteria (Booking & Cancellation)

### Scenario 1: STORY-BK-02 (Booking an Open Slot - Positive)
```gherkin
Scenario: Patient successfully books an available slot
  Given patient "Maria" is logged into the hospital mobile app
  And Dr. Finch has an open slot on "2026-11-20 at 10:00 AM"
  When Maria selects the "10:00 AM" slot and confirms the booking
  Then the appointment status becomes "CONFIRMED"
  And the slot "10:00 AM" is immediately locked on Dr. Finch's calendar
  And a confirmation SMS with appointment reference number is sent to Maria's phone
```

### Scenario 2: STORY-BK-02 (Slot Already Taken / Concurrency Conflict - Negative)
```gherkin
Scenario: Two patients attempt to book the exact same slot simultaneously
  Given patient "John" and patient "David" are viewing Dr. Finch's "10:00 AM" slot at the same time
  When John clicks "Confirm Booking" first and successfully locks the slot
  And David clicks "Confirm Booking" 2 seconds later
  Then David's transaction is safely rolled back
  And an alert displays "Sorry, this slot was just taken by another patient. Please select another time."
  And Dr. Finch's calendar refreshes displaying "10:00 AM" as unavailable
```

### Scenario 3: STORY-RC-06 (Successful Appointment Cancellation - Positive)
```gherkin
Scenario: Patient cancels appointment within permitted cancellation window
  Given patient "Sarah" has a confirmed appointment with Dr. Cuddy for tomorrow at 2:00 PM
  And the current time is more than 2 hours before the appointment
  When Sarah opens appointment details and clicks "Cancel Appointment"
  And confirms the cancellation prompt
  Then the appointment status updates to "CANCELLED"
  And the slot "2:00 PM" is returned to the pool of available consultation slots
  And Sarah receives a cancellation confirmation push notification
```

### Scenario 4: STORY-RC-06 (Late Cancellation Window - Negative Boundary)
```gherkin
Scenario: Patient attempts to cancel within the 2-hour emergency cutoff window
  Given patient "Kevin" has an appointment with Dr. House scheduled for today at 3:00 PM
  And the current local time is 1:45 PM (less than 2 hours before visit)
  When Kevin attempts to click "Cancel Appointment"
  Then the cancellation button is disabled
  And a message displays "Cancellations within 2 hours of consultation must be made directly by calling the hospital desk at 1-800-HOSPITAL."
```

---

## 5. Story Point vs. Hour & Prioritized Backlog

### Conceptual Difference: Story Points vs. Hours

```
+----------------------------------------------------------------------------------------------------+
| PARAMETER             | STORY POINTS (RELATIVE ESTIMATION)     | IDEAL HOURS (ABSOLUTE TIME)       |
+----------------------------------------------------------------------------------------------------+
| Nature                | Relative measure of Size, Complexity,  | Absolute measure of clock time    |
|                       | Uncertainty, and Effort.               | spent by a specific individual.   |
| Experience Variance   | Stable across the entire Scrum Team.   | Highly variable: Senior takes 2h, |
|                       | (A 5-pt story is 5 pts for everyone).  | Junior takes 12h for same task.   |
| Psychological Impact  | Encourages team-wide collaboration     | Drives micromanagement, false     |
|                       | and collective ownership.              | precision, and individual blame.  |
| Non-Linear Growth     | Uses Fibonacci scale (1,2,3,5,8,13) to | Linear arithmetic fails to model  |
|                       | reflect exponential risk as size grows.| rising uncertainty on big tasks.  |
+----------------------------------------------------------------------------------------------------+
```

### Prioritized Hospital Backlog (Business Value vs. Effort)

| Story ID | Epic | Story Summary | Business Value (1-100) | Effort Points (Fibonacci) | Value/Effort Priority |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **STORY-BK-02** | Booking | Available Slot Grid Selection | **95** | **3 (Ref)** | **P1 (Highest ROI)** |
| **STORY-BK-01** | Booking | Doctor Specialty Discovery | **90** | **3** | **P1** |
| **STORY-BK-04** | Booking | Booking Confirmation & QR Pass | **85** | **3** | **P1** |
| **STORY-RC-06** | Rescheduling | One-Click Cancellation | **85** | **3** | **P1** |
| **STORY-RN-08** | Reminders | 24h & 2h Push/SMS Alerts | **90** | **5** | **P1 (Cuts No-Shows)** |
| **STORY-BK-03** | Booking | Patient Details & Symptoms Intake | **70** | **3** | **P2** |
| **STORY-RC-05** | Rescheduling | Self-Service Reschedule | **80** | **5** | **P2** |
| **STORY-DM-11** | Doctor Schedule| Emergency Leave / Slot Blocking | **75** | **5** | **P2** |
| **STORY-RN-09** | Reminders | Pre-Visit Clinical Preparation | **65** | **3** | **P2** |
| **STORY-RN-10** | Reminders | Native Phone Calendar Sync | **55** | **2** | **P3** |
| **STORY-RC-07** | Rescheduling | Waitlist Slot Redistribution | **60** | **8** | **P3** |
| **STORY-DM-12** | Doctor Schedule| Auto-Reassignment on Absence | **50** | **8** | **P3** |
| **TOTAL** | | **12 User Stories** | | **51 Points** | |

---

## 6. Definition of Ready (DoR) & Definition of Done (DoD)

### Definition of Ready (DoR) &ndash; 6 Minimum Checklist Items:
- [x] **1. Clear Value Formulation:** Story written in standard *As a... I want... So that...* template with explicit medical persona.
- [x] **2. Given/When/Then Acceptance Criteria:** Minimum of 2 positive and 1 negative/boundary scenarios documented.
- [x] **3. UI/UX Wireframes Attached:** Mobile interface mockups and clinical error states reviewed by clinical operations and developers.
- [x] **4. Dependencies Cleared:** Hospital EMR FHIR endpoint schemas and SMS gateway credentials verified accessible.
- [x] **5. INVEST Conformance & Sized:** Story evaluated via Planning Poker and sized at $\le 8$ story points.
- [x] **6. Compliance & Privacy Tagging:** HIPAA/NABH data privacy requirements tagged (e.g. medical reason masking on notifications).

### Definition of Done (DoD) &ndash; 6 Minimum Checklist Items:
- [x] **1. Peer Review Approved:** All code merged via Git Pull Request with approval from at least 1 Senior Developer.
- [x] **2. Automated Test Coverage:** Unit test coverage $\ge 85\%$; all regression suites pass in CI/CD pipeline.
- [x] **3. Concurrency & Performance Tested:** Double-booking concurrency tests verify that race conditions cannot lock the same slot twice.
- [x] **4. Acceptance Criteria Passed:** All Given/When/Then scenarios validated on staging device by QA and Product Owner.
- [x] **5. Zero Vulnerabilities:** Static analysis via SonarQube shows zero Blocker, Critical, or OWASP Top-10 vulnerabilities.
- [x] **6. Deployed & Monitored:** Increment deployed to staging environment with application telemetry logging (Prometheus/Grafana) active.
