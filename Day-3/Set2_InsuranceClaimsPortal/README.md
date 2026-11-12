# Day 3 – Agile and Scrum: Foundations and Backlog Workshop
## Set 2: Insurance Claims Portal

---

## 1. Product Vision & Waterfall vs. Agile Analysis

### Product Vision Statement
> **"For** insured policyholders facing stressful accident, health, or property loss events,  
> **Who** require fast, transparent, and empathetic claims reimbursement,  
> **The Insurance Claims Portal** is a digital self-service web and mobile platform  
> **That** enables instant first notice of loss (FNOL) lodging, mobile document and photo uploading, and real-time claim settlement tracking,  
> **Unlike** traditional manual paper-based filing requiring weeks of postal exchanges and opaque call-center queues,  
> **Our product** settles simple claims within 48 hours via automated straight-through processing (STP) and provides transparent milestone visibility."

---

### Waterfall vs. Agile Comparison for Claims Portal (Half-Page Analysis)

```
+---------------------------------------------------------------------------------------------------+
| COMPARATIVE PARAMETER  | WATERFALL METHODOLOGY                  | AGILE / SCRUM FRAMEWORK         |
+---------------------------------------------------------------------------------------------------+
| Requirement Evolution  | Fixed upfront in 200-page BRD.         | Emergent backlog. Features      |
|                        | Changes incur heavy change-requests.   | refined sprint-by-sprint.       |
| Time-to-Market         | 12-18 months before any customer sees  | Working increment delivered     |
|                        | a functional screen. High market risk. | every 2-week sprint.            |
| Customer Feedback Loop | Late: only during UAT right before     | Continuous: Customer & Claims   |
|                        | release when changes are costly.       | adjusters review working demo.  |
| Regulatory & Fraud     | Discovered late; changes delay entire  | Incremental compliance tests    |
| Compliance             | launch schedule.                       | embedded in sprint DoD.         |
| Team Morale & Risk     | High panic during late integration;    | Predictable sustainable pace;   |
|                        | single point of catastrophic failure.  | rapid early failure/recovery.   |
+---------------------------------------------------------------------------------------------------+
```

#### Why Agile Suits the Claims Portal Programme:
1. **Changing Insurance Regulations & Policy Rules:** State insurance commissions frequently alter claim adjudication rules and claim disclosure mandates. Agile allows the Product Owner to adapt sprint goals immediately without contractual renegotiation.
2. **Mitigating Complex Integration Risk:** The portal must interface with legacy policy administration mainframes, external fraud databases, and banking payment rails. Iterative vertical slicing surfaces interface defects in Sprint 1 rather than after 12 months.
3. **Immediate Value Realization:** Policyholders can begin using basic FNOL registration (Sprint 1-2) months before automated AI fraud assessment modules are added in subsequent iterations.

---

## 2. Four Epics & 13 User Stories

### Epic 1: Claim Registration (CR)
- **STORY-CR-01 (Policy Selection & Auto-Fill):**
  *As an* insured customer,  
  *I want to* select from my active insurance policies and have vehicle/property details pre-populated,  
  *So that* I do not have to look up policy reference numbers during an emergency.
- **STORY-CR-02 (Incident Date, Time, and Location Entry):**
  *As a* claimant,  
  *I want to* specify the incident date, time, and GPS/street location with incident description,  
  *So that* the insurer can establish jurisdiction and coverage timeline.
- **STORY-CR-03 (Third-Party & Police Report Details):**
  *As an* auto insurance claimant,  
  *I want to* enter third-party driver information, vehicle registration, and police report numbers,  
  *So that* subrogation and liability can be evaluated.
- **STORY-CR-04 (Claim Submission & FNOL Tracking Number):**
  *As a* claimant completing the form,  
  *I want to* submit my first notice of loss and receive an instant unique claim reference number (e.g. `CLM-2026-8812`),  
  *So that* I have verifiable proof of submission.

### Epic 2: Document Upload (DU)
- **STORY-DU-05 (Mobile Camera & Photo Upload):**
  *As a* claimant at the scene of an accident,  
  *I want to* snap and upload damage photos directly from my mobile camera,  
  *So that* I can provide visual evidence before vehicles are moved.
- **STORY-DU-06 (PDF & Multi-Format Document Ingestion):**
  *As an* insured policyholder,  
  *I want to* upload medical bills, repair estimates, and police reports in PDF, PNG, or JPG formats up to 25MB,  
  *So that* all documentation is attached to my claim record.
- **STORY-DU-07 (Automated Document Completeness Validation):**
  *As an* adjuster review assistant,  
  *I want to* automatically validate that uploaded files are virus-free, legible, and uncorrupted,  
  *So that* claims are not delayed by broken or unreadable attachments.

### Epic 3: Claim Tracking (CT)
- **STORY-CT-08 (Milestone Status Visual Tracker):**
  *As an* anxious claimant,  
  *I want to* see a visual progress timeline showing whether my claim is in *Submitted, Under Review, Assessment, or Approved* status,  
  *So that* I know exactly where my claim stands without calling customer care.
- **STORY-CT-09 (Assigned Adjuster Contact Card):**
  *As a* customer with an active claim,  
  *I want to* view the name, direct extension, and email of my assigned claims adjuster,  
  *So that* I can communicate directly with the decision-maker.
- **STORY-CT-10 (Pending Action / Missing Document Alert):**
  *As a* claimant,  
  *I want to* see highlighted action banners if the adjuster requests additional invoices or statements,  
  *So that* I can resolve impediments promptly.

### Epic 4: Settlement Notifications (SN)
- **STORY-SN-11 (Email & SMS Adjudication Alerts):**
  *As an* insured customer,  
  *I want to* receive automated SMS and email alerts whenever my claim changes status or reaches approval,  
  *So that* I am immediately aware of progress.
- **STORY-SN-12 (Settlement Breakdown & Explanation of Benefits):**
  *As a* policyholder receiving payout,  
  *I want to* view an itemized breakdown of approved repairs, deductible deductions, and net payout,  
  *So that* I understand how the settlement calculation was derived.
- **STORY-SN-13 (Direct Bank Account Payout Selection):**
  *As an* approved claimant,  
  *I want to* provide direct deposit bank account details for ACH/wire transfer,  
  *So that* funds are deposited safely into my bank account within 24 hours of approval.

---

## 3. INVEST Review & Vertical Story Splitting

### The Anti-Pattern: Horizontal / Architectural Layer Splitting
A common Scrum mistake is splitting a user story horizontally across technical tiers:
- *Layer Story A:* "Build Claims Database Schema" (0 user value)
- *Layer Story B:* "Write Spring Boot Claims REST API" (0 user value)
- *Layer Story C:* "Build React Claims Form UI" (0 user value until integrated)

### Vertical Slicing Solution:
A vertical slice cuts through all architectural layers (Database, Business Logic, Security, UI) to deliver a thin, end-to-end working feature that provides testable customer value within the sprint.

#### Splitting Huge Story: "Manage All Claims and Evidence" (13+ Points)
- **Vertical Slice 1 (STORY-CR-01):** Pre-populate policy data and capture basic incident timestamp/location (5 pts).
- **Vertical Slice 2 (STORY-DU-05):** Upload mobile camera photos to secure S3 storage linked to the claim (5 pts).
- **Vertical Slice 3 (STORY-CT-08):** Display read-only 4-stage visual milestone tracker (3 pts).
- **Result:** Each story is now small, independent, testable, and delivers verifiable user value at sprint review.

---

## 4. Given / When / Then Acceptance Criteria (Claim Registration)

### Scenario 1: STORY-CR-01 (Policy Selection & Auto-Fill - Positive)
```gherkin
Scenario: Eligible policyholder selects active policy for claim lodging
  Given a customer is logged into the claims self-service portal
  And has two active auto insurance policies ("POL-AUTO-101" and "POL-AUTO-202")
  When the customer clicks "File New Claim"
  Then the portal displays both active policies with vehicle make, model, and registration numbers
  When the customer selects "POL-AUTO-101"
  Then the claim form pre-populates the vehicle VIN and primary driver details
  And enables the "Next: Incident Details" button
```

### Scenario 2: STORY-CR-02 (Incident Date Validation - Negative Scenario)
```gherkin
Scenario: Claimant enters invalid future incident date or date prior to policy inception
  Given a customer is filing a claim on policy "POL-AUTO-101" with policy inception date "2026-01-01"
  When the customer selects an incident date of "2026-12-25" (future date)
  Then the date field is outlined in red
  And an error message displays "Incident date cannot be in the future"
  And the "Submit Claim" button remains disabled
```

### Scenario 3: STORY-CR-04 (FNOL Submission & Reference Generation - Positive)
```gherkin
Scenario: Successful submission of First Notice of Loss (FNOL)
  Given the claimant has completed all mandatory incident descriptions and declarations
  When the claimant clicks "Confirm and Submit Claim"
  Then the system records the claim in the central claims repository
  And generates an immutable unique Claim ID with format "CLM-YYYY-XXXXX"
  And sends an immediate confirmation SMS and email containing the Claim ID
  And transitions the customer to the "Track My Claim" summary screen
```

---

## 5. Planning Poker Estimation & Outlier Discussion

### Backlog Estimation Table (Fibonacci: 1, 2, 3, 5, 8, 13)

| Story ID | Epic | User Story Summary | Story Points | Discussion & Rationale |
| :--- | :--- | :--- | :---: | :--- |
| **STORY-CR-01** | Claim Reg | Policy Selection & Auto-Fill | **3** | Core DB query against policy service; straightforward form binding. |
| **STORY-CR-02** | Claim Reg | Incident Date, Time & Location | **3** | Location autofill with validation rules and boundary checking. |
| **STORY-CR-03** | Claim Reg | Third-Party & Police Report Entry | **3** | Standard form input with conditional third-party data fields. |
| **STORY-CR-04** | Claim Reg | FNOL Submission & Claim Reference | **5** | Transmits to core claims engine; transactional safety required. |
| **STORY-DU-05** | Document Upload | Mobile Camera & Photo Upload | **5** | Mobile browser hardware access, image resizing, and AWS S3 upload. |
| **STORY-DU-06** | Document Upload | PDF & Multi-Format Attachment | **3** | Standard multipart upload with mime-type filtering. |
| **STORY-DU-07** | Document Upload | Automated File Validation & Anti-Virus| **5** | Asynchronous Lambda ClamAV scanning and OCR legibility check. |
| **STORY-CT-08** | Claim Tracking | Milestone Status Visual Tracker | **3** | Read-only state machine UI driven by backend events. |
| **STORY-CT-09** | Claim Tracking | Assigned Adjuster Contact Card | **2** | Reference story; simple user profile card component. |
| **STORY-CT-10** | Claim Tracking | Missing Document Action Banner | **3** | Conditional alert banner driven by adjuster task status. |
| **STORY-SN-11** | Settlement | Email & SMS Adjudication Alerts | **3** | Event-driven notification worker (AWS SNS/SendGrid). |
| **STORY-SN-12** | Settlement | Settlement Breakdown & EOB | **5** | Financial ledger calculation, deductible logic, and PDF export. |
| **STORY-SN-13** | Settlement | Direct Bank Account Deposit (ACH) | **8** | Banking ACH gateway integration, routing number validation. |
| **TOTAL** | | **13 User Stories** | **51 Points** | **Average velocity 25 pts/sprint &rarr; 2 Sprints to MVP** |

### Outlier Discussion on STORY-SN-13 (Direct Deposit ACH):
- **Initial Planning Poker Votes:** Developer A: `3`, Developer B: `5`, Developer C: `13`, QA Engineer: `13`.
- **Discussion:**
  - *Developer A (voted 3):* "It's just an API call sending account number and routing number."
  - *Developer C (voted 13):* "We are dealing with real money transfers. We need NACHA format validation, micro-deposit verification, bank routing lookup API, webhook event listeners for ACH reversals, and compliance with anti-money laundering (AML) controls."
  - *Consensus Reached:* The team agreed that the regulatory validation and idempotency handling make the story an **8 Story Point** item.

---

## 6. JIRA Project Configuration & Definition of Done

### JIRA Workflow States:
```
[ TO DO ] ----> [ IN PROGRESS ] ----> [ IN REVIEW / PR ] ----> [ IN QA ] ----> [ DONE ]
```

### Definition of Done (DoD) for Insurance Claims Portal:
1. **Code Quality:** All Java/Spring Boot code adheres to SonarQube quality gates (Zero Blocker/Critical bugs).
2. **Automated Testing:** Unit test coverage $\ge 85\%$; automated integration tests pass for core claim state transitions.
3. **Security & PII Compliance:** All customer Personal Identifiable Information (PII) and banking data encrypted at rest (AES-256) and in transit (TLS 1.3).
4. **Acceptance Verification:** Product Owner verifies all Given/When/Then scenarios on staging environment.
5. **Accessibility:** UI verified against WCAG 2.1 Level AA standards.
6. **Documentation & Release:** Swagger API schema published, migration scripts version-controlled with Flyway.
