# Day 3 – Agile and Scrum: Foundations and Backlog Workshop

**Author:** Pratap Sakthivel  
**Repository:** [PratapSakthivel/Hexaware-Homeworks](https://github.com/PratapSakthivel/Hexaware-Homeworks)  
**Topics Covered:** Agile Overview · Scrum Roles, Events and Artifacts · User Stories, Backlog Refinement, INVEST Criteria, Acceptance Criteria (Given/When/Then), Story Points vs. Hours, MoSCoW Prioritisation, and JIRA Board Configuration  

---

## Directory Overview

```
Day-3/
├── README.md                                   # Master overview of Day 3 Agile/Scrum workshop
├── Set1_OnlineGroceryDelivery/
│   └── README.md                               # Vision, roles & anti-patterns, 12 stories, INVEST rewrites, MoSCoW, DoR/DoD
├── Set2_InsuranceClaimsPortal/
│   └── README.md                               # Vision, Waterfall vs Agile, 13 stories, vertical slicing, Planning Poker outlier, JIRA DoD
└── Set3_HospitalAppointmentBooking/
    └── README.md                               # Vision, stakeholder mapping, 12 stories, Given/When/Then, Points vs Hours, 6-item DoR/DoD
```

---

## Summary of Completed Sets & Agile Deliverables

### 1. [Set 1: Online Grocery Delivery Application](./Set1_OnlineGroceryDelivery/README.md)
- **Product Vision:** Customer-centric vision for regional 60-minute fresh grocery delivery.
- **Scrum Roles & Anti-Patterns:** Explored real-world dysfunctions (The "Order Taker" Product Owner, "Team Boss" Scrum Master, and "Siloed Specialists" Developers) with corrective Scrum practices.
- **Backlog & INVEST:** 3 Epics (*Browse and Search*, *Cart and Checkout*, *Delivery Tracking*) broken into 12 user stories. Two failing stories rewritten to satisfy the INVEST checklist.
- **Acceptance Criteria:** 5 detailed Gherkin *Given/When/Then* scenarios including negative edge cases (out of stock, card payment failure).
- **Estimation & Prioritisation:** Prioritized using **MoSCoW**; estimated using Fibonacci Planning Poker ($48\text{ total story points}$) with justified reference baseline.
- **Governance:** Detailed checklists for Definition of Ready (DoR) and Definition of Done (DoD).

---

### 2. [Set 2: Insurance Claims Portal](./Set2_InsuranceClaimsPortal/README.md)
- **Product Vision & Methodology Comparison:** Concise half-page comparative analysis contrasting **Waterfall vs. Agile** and demonstrating why iterative delivery is vital for claims compliance and early ROI.
- **Epics & Stories:** 4 Epics (*Claim Registration*, *Document Upload*, *Claim Tracking*, *Settlement Notifications*) broken into 13 user stories.
- **Vertical Story Splitting:** Applied vertical slicing across DB, API, security, and UI layers to eliminate horizontal architectural silos.
- **Acceptance Criteria:** Rigorous validation scenarios for First Notice of Loss (FNOL) including future date validation failure.
- **Planning Poker & Outliers:** 51 total story points; detailed documentation of outlier consensus discussion on ACH direct deposit handling.
- **JIRA Configuration:** Configured JIRA board states (*To Do &rarr; In Progress &rarr; In Review/PR &rarr; In QA &rarr; Done*) and attached financial DoD.

---

### 3. [Set 3: Hospital Appointment Booking Application](./Set3_HospitalAppointmentBooking/README.md)
- **Stakeholder Mapping:** Mapped hospital roles (Chief Medical Officer, Agile Coach, Mobile Engineers, Patients, Physicians) to Scrum roles.
- **Epics & Stories:** 4 Epics (*Appointment Booking*, *Rescheduling and Cancellation*, *Reminders and Notifications*, *Doctor Schedule Management*) split into 12 user stories.
- **Given / When / Then Acceptance Criteria:** Concrete scenarios covering slot booking, cancellation boundaries (2-hour emergency cutoff), and the critical **concurrency race condition ("slot already taken")**.
- **Relative Estimation Rationale:** In-depth explanation of how **Story Points** (relative size/complexity) differ fundamentally from **Ideal Hours** (clock time).
- **Prioritization:** Ranked stories by Business Value vs. Effort ($51\text{ total points}$).
- **DoR & DoD:** Six concrete checklist items defined for both Definition of Ready and Definition of Done.
