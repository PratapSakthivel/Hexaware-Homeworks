# Day 3 – Agile and Scrum: Foundations and Backlog Workshop
## Set 1: Online Grocery Delivery Application

---

## 1. Product Vision Statement & Scrum Roles

### Product Vision Statement
> **"For** busy regional households and families seeking convenient, fresh, and dependable groceries,  
> **Who** want to avoid long supermarket queues and unpredictable stockouts,  
> **The Online Grocery Delivery Application** is a seamless omnichannel mobile and web platform  
> **That** delivers locally sourced farm-fresh produce and daily household essentials within a guaranteed 60-minute delivery window or scheduled slot,  
> **Unlike** generic national retail delivery apps with delayed dispatch and inconsistent fresh-item quality,  
> **Our product** provides real-time aisle stock availability, direct store-to-door temperature-monitored delivery, and hyper-local order tracking."

---

### Scrum Roles & Anti-Patterns

| Scrum Role | Core Responsibility | Real-World Anti-Pattern | Corrective Scrum Practice |
| :--- | :--- | :--- | :--- |
| **Product Owner (PO)** | Maximizes the value of the product resulting from the work of the Scrum Team; sole owner of the Product Backlog. | **The Order Taker / Proxy PO:** Acts merely as a conduit passing unfiltered stakeholder demands directly into sprints without prioritization, value justification, or decision-making authority. | The PO must have explicit empowerment from executive sponsors to say "No" to non-priority requests, manage tradeoffs, and order backlog items purely based on ROI, customer value, and technical debt. |
| **Scrum Master (SM)** | Accountable for establishing Scrum as defined in the Scrum Guide; facilitates events and removes impediments. | **The Team Boss / Project Manager in Disguise:** Assigns tasks to developers, demands individual status reports in daily standups, and commands sprint commitments instead of coaching self-management. | The SM is a servant-leader and coach who ensures Scrum theory is understood, facilitates team-driven problem solving, and shields developers from external interruptions. |
| **Developers** | Accountable for creating a plan for the Sprint (Sprint Backlog), instilling quality, and delivering a Done Increment. | **Siloed "Throw-it-over-the-wall" Specialization:** Frontend, backend, and QA engineers only touch their specific domain, refusing to collaborate or test cross-functional work during the sprint. | Developers share collective ownership of the Sprint Goal; cross-functional pairing and mobbing ensure that testing, integration, and deployment happen continuously within the sprint window. |

---

## 2. Epics & 12 User Stories

### Epic 1: Browse and Search (BS)
- **STORY-BS-01 (Category Navigation):**
  *As a* shopper,  
  *I want to* browse grocery items organized by intuitive categories (e.g., Dairy, Bakery, Farm Fresh, Frozen),  
  *So that* I can quickly locate the section I want without typing.
- **STORY-BS-02 (Keyword Search with Autocomplete):**
  *As a* customer looking for specific groceries,  
  *I want to* receive real-time search suggestions and brand autocompletions as I type,  
  *So that* I can find items in fewer keystrokes.
- **STORY-BS-03 (Dietary & Brand Filtering):**
  *As a* health-conscious buyer,  
  *I want to* filter search results by dietary preferences (Gluten-Free, Organic, Vegan, Low-Sodium),  
  *So that* I only view products that match my family's dietary requirements.
- **STORY-BS-04 (Real-Time Stock Availability Indicator):**
  *As a* registered customer,  
  *I want to* see immediate live stock indicators (e.g., "In Stock", "Only 2 Left", "Out of Stock") based on my local store branch,  
  *So that* I avoid ordering items that cannot be fulfilled.

### Epic 2: Cart and Checkout (CC)
- **STORY-CC-05 (Dynamic Cart & Subtotal Management):**
  *As a* shopper,  
  *I want to* adjust item quantities, add packaging notes, and view real-time running subtotals with tax estimates in my cart,  
  *So that* I stay within my planned grocery budget before proceeding.
- **STORY-CC-06 (Delivery Slot Selection):**
  *As a* busy professional,  
  *I want to* select an available 1-hour home delivery slot or express 60-minute delivery window,  
  *So that* I can ensure someone is home to receive perishable items.
- **STORY-CC-07 (Multi-Option Payment Integration):**
  *As a* customer ready to purchase,  
  *I want to* pay securely using Credit/Debit Card, UPI/Digital Wallets, or Cash/Card on Delivery,  
  *So that* I can complete my transaction using my preferred payment method.
- **STORY-CC-08 (Out-of-Stock Substitution Preferences):**
  *As a* buyer checking out,  
  *I want to* designate substitution rules for perishable items (e.g., "Substitute with same brand organic", "Contact me first", "Do not substitute"),  
  *So that* personal pickers fulfill my order accurately if stock runs out.

### Epic 3: Delivery Tracking (DT)
- **STORY-DT-09 (Live Driver Dispatch & GPS Tracking):**
  *As a* customer waiting for my groceries,  
  *I want to* track the delivery driver's real-time vehicle location on an interactive map once dispatched,  
  *So that* I know exactly when my groceries will arrive at my doorstep.
- **STORY-DT-10 (Order Status Push & SMS Notifications):**
  *As an* online shopper,  
  *I want to* receive automated notifications at each fulfillment stage (Order Placed, Picking Complete, Out for Delivery, Delivered),  
  *So that* I am kept informed without manually refreshing the app.
- **STORY-DT-11 (Contactless Delivery Instructions):**
  *As an* apartment resident,  
  *I want to* specify delivery drop-off instructions and gate codes (e.g., "Leave at front doorstep, ring bell"),  
  *So that* the driver safely drops the groceries without physical contact.
- **STORY-DT-12 (Post-Delivery Digital Receipt & Rating):**
  *As a* customer who received an order,  
  *I want to* view the itemized digital invoice, rate the picker and driver, and report missing or damaged items,  
  *So that* issues are promptly credited to my account.

---

## 3. INVEST Checklist Review & Story Rewrites

### The INVEST Criteria:
- **I**ndependent: Can be developed, tested, and released independently.
- **N**egotiable: Not an immutable contract; open to discussion.
- **V**aluable: Delivers clear value to users or customers.
- **E**stimable: Development team understands the scope sufficiently to estimate effort.
- **S**mall: Sized appropriately to be completed comfortably within a single sprint.
- **T**estable: Clear acceptance criteria allow automated and manual verification.

### Two Failing Stories Rewritten:

#### Failing Story #1: Technical Monolith (Failed: Independent, Small, Testable)
- **Original Bad Story:**  
  *"As a system admin, I want to build the entire checkout backend, Stripe integration, payment fraud gateway, and email receipt subsystem so that users can checkout."*
- **Why it failed INVEST:**
  - **Not Small:** Giant compound story spanning 3 technical subsystems (20+ points).
  - **Not Independent:** Intertwined payment, database, and notification layers.
  - **Not Testable:** Too many concurrent failure paths to verify in one sprint increment.
- **Rewritten INVEST-Compliant Story:**
  - **STORY-CC-07 (Multi-Option Payment Integration):**  
    *As a customer ready to purchase,*  
    *I want to pay securely via credit card tokenization through an integrated payment gateway,*  
    *So that I can immediately complete my transaction with instant payment authorization.*

#### Failing Story #2: Vague Non-Functional Statement (Failed: Estimable, Valuable, Testable)
- **Original Bad Story:**  
  *"As a user, I want the grocery search to be super fast and responsive so that it works well."*
- **Why it failed INVEST:**
  - **Not Estimable:** "Super fast" and "works well" are subjective adjectives without boundary.
  - **Not Testable:** No measurable metric or pass/fail threshold.
  - **Not Negotiable:** Lacks clear business feature context.
- **Rewritten INVEST-Compliant Story:**
  - **STORY-BS-02 (Keyword Search with Autocomplete):**  
    *As a customer looking for specific groceries,*  
    *I want to see search autocompletions within 250 milliseconds of typing 3 characters,*  
    *So that I can quickly select matching items without full manual typing.*

---

## 4. Given / When / Then Acceptance Criteria (5 Stories)

### Scenario 1: STORY-BS-02 (Search with Autocomplete - Positive)
```gherkin
Scenario: Successful keyword search with real-time autocompletion
  Given a customer is on the grocery app home screen with a stable internet connection
  When the customer types "org" into the main search field
  Then the dropdown suggestion panel displays within 250 milliseconds
  And matching items such as "Organic Milk", "Organic Eggs", and "Organic Bananas" are listed
  And each suggestion displays product thumbnail, brand, and pack size
```

### Scenario 2: STORY-BS-04 (Real-Time Stock Availability - Negative / Edge Scenario)
```gherkin
Scenario: Item goes out of stock while browsing
  Given a customer has viewed "Farm Fresh Strawberries 500g" which has only 1 unit remaining in store inventory
  When another user purchases that last unit before this customer adds it to the cart
  And this customer clicks "Add to Cart"
  Then the system prevents adding the item to the cart
  And an alert banner displays "Sorry, this item just went out of stock at your local branch"
  And the product badge dynamically updates to a disabled "Out of Stock" button
```

### Scenario 3: STORY-CC-06 (Delivery Slot Selection - Positive)
```gherkin
Scenario: Customer reserves an available delivery time slot
  Given the customer has items in their cart meeting the minimum order value of $20.00
  When the customer navigates to the delivery scheduling screen
  Then available 1-hour time slots for today and tomorrow are displayed with cutoff indicators
  When the customer selects "Today: 4:00 PM - 5:00 PM"
  Then that slot is reserved for 15 minutes while the customer completes checkout
```

### Scenario 4: STORY-CC-07 (Card Payment Processing - Negative Scenario)
```gherkin
Scenario: Card transaction declined due to insufficient funds
  Given the customer is at the final payment step with an order total of $64.50
  When the customer submits a credit card payment that returns bank decline code "51: Insufficient Funds"
  Then the order is not placed and no payment is captured
  And an error message states "Your payment was declined by your bank. Please use an alternative payment method."
  And the customer remains on the checkout screen with cart contents preserved
```

### Scenario 5: STORY-DT-09 (Live GPS Driver Dispatch - Positive)
```gherkin
Scenario: Customer tracks active grocery delivery
  Given an order has been picked, packed, and assigned to delivery driver "Marcus"
  When the driver marks the order as "Out for Delivery" in the driver app
  Then the customer app displays a live GPS map view with the driver's vehicle icon
  And displays the estimated time of arrival (ETA) updated every 15 seconds
  And provides a masked "Call Driver" button for delivery coordination
```

---

## 5. Prioritized Backlog (MoSCoW & Planning Poker)

### Justification of Reference Story:
- **Reference Story:** `STORY-BS-01 (Category Navigation)` = **2 Story Points**.
- **Rationale:** A clean category hierarchy read with established API endpoints, standard UI grid rendering, and static routing represents the team's golden baseline of low complexity, well-understood UI/UX, and minimal risk.

| Story ID | Epic | User Story Summary | MoSCoW Priority | Planning Poker Points | Justification of Estimate |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **STORY-BS-01** | Browse & Search | Category Navigation | **Must Have** | **2 (Ref)** | Reference baseline; standard CRUD listing and responsive grid. |
| **STORY-BS-02** | Browse & Search | Keyword Search with Autocomplete | **Must Have** | **3** | Requires debounced search index query with Elasticsearch/Redis caching. |
| **STORY-BS-04** | Browse & Search | Real-Time Stock Availability Indicator | **Must Have** | **5** | Complex socket/polling event syncing warehouse branch inventory. |
| **STORY-CC-05** | Cart & Checkout | Dynamic Cart & Subtotal Management | **Must Have** | **3** | Local state + server cart sync, coupons, tax calculations. |
| **STORY-CC-06** | Cart & Checkout | Delivery Slot Selection | **Must Have** | **5** | Concurrency locking for slot booking capacity per store. |
| **STORY-CC-07** | Cart & Checkout | Multi-Option Payment Integration | **Must Have** | **8** | PCI-DSS compliant payment gateway, webhooks, idempotency keys. |
| **STORY-DT-10** | Delivery Tracking| Order Status Push & SMS Notifications | **Must Have** | **3** | Event-driven notification service (Twilio/Firebase integration). |
| **STORY-BS-03** | Browse & Search | Dietary & Brand Filtering | **Should Have** | **3** | Multi-faceted relational filtering on product attributes. |
| **STORY-CC-08** | Cart & Checkout | Out-of-Stock Substitution Rules | **Should Have** | **3** | Decision tree storage and picker workflow integration. |
| **STORY-DT-09** | Delivery Tracking| Live Driver GPS Tracking | **Should Have** | **8** | Driver telemetry streaming, Google Maps SDK, battery optimization. |
| **STORY-DT-11** | Delivery Tracking| Contactless Delivery Instructions | **Could Have** | **2** | Text input storage and display on picker/driver manifest. |
| **STORY-DT-12** | Delivery Tracking| Post-Delivery Invoice & Rating | **Could Have** | **3** | PDF generation, feedback review system, wallet refund trigger. |
| **TOTAL** | | **12 User Stories** | | **48 Points** | **Sprint 1 (Must Haves) = 29 Pts; Sprint 2 = 19 Pts** |

---

## 6. JIRA Board Architecture & DoR / DoD

### Definition of Ready (DoR) Checklist:
1. User story is written in standard format: *As a... I want... So that...*
2. Acceptance criteria written in unambiguous *Given/When/Then* format.
3. Wireframes/UI design mockups attached and reviewed by developers.
4. All external API dependencies and data contracts identified.
5. Story has been estimated via Planning Poker and meets the INVEST criteria (<= 8 points).
6. Non-functional performance, accessibility, and security guidelines stated.

### Definition of Done (DoD) Checklist:
1. Production code written, peer-reviewed via Pull Request with at least 1 approval.
2. Unit tests written with $\ge 85\%$ line coverage; all automated tests pass in CI/CD pipeline.
3. Acceptance criteria verified in Staging/QA environment by QA engineer and Product Owner.
4. Zero critical or high-severity SonarQube static analysis vulnerabilities.
5. API documentation updated in Swagger/Postman collection.
6. Deployed to staging and verified with zero regression defects.
