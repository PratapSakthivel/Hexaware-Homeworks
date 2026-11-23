# Set 1: Loan Eligibility Engine – Test Inputs & Output Verification

## 1. Test Inputs and Expected Decision Matrix

| Applicant ID | Name | Age | Monthly Income (₹) | EMI (₹) | EMI Ratio | Score | Employment | Active Loans | Decision | Loan Product | Rate (%) | Primary Underwriting Rationale |
|:---|:---|:---:|:---:|:---:|:---:|:---:|:---|:---:|:---|:---|:---:|:---|
| `APP-101` | Arun Kumar | 28 | 85,000 | 22,000 | 25.9% | 810 | SALARIED | 1 | **APPROVED** | PRIME_SUPER_EXPRESS | 8.25 | Prime credit tier (Score $\ge 780$). |
| `APP-102` | Priya Nair | 34 | 120,000 | 45,000 | 37.5% | 745 | SALARIED | 0 | **APPROVED** | STANDARD_HOME_SECURE | 9.10 | Standard credit tier ($720 \le \text{Score} < 780$). |
| `APP-103` | Karthik Raja | 19 | 40,000 | 12,000 | 30.0% | 700 | SALARIED | 0 | **REJECTED** | NONE | 0.00 | Underage ($19 < 21$ legal minimum). |
| `APP-104` | Sneha Patel | 42 | 90,000 | 58,000 | 64.4% | 760 | SELF_EMPLOYED | 1 | **REJECTED** | NONE | 0.00 | Debt ratio excessive ($64.4\% > 50.0\%$). |
| `APP-105` | Deepak Verma | 31 | 65,000 | 18,000 | 27.7% | 675 | SALARIED | 1 | **APPROVED** | SUBPRIME_CREDIT_BUILDER | 11.50 | Fair credit tier ($650 \le \text{Score} < 720$). |
| `APP-106` | Rohan Gupta | 65 | 150,000 | 25,000 | 16.7% | 820 | SALARIED | 0 | **REJECTED** | NONE | 0.00 | Overage ($65 > 60$ retirement limit). |
| `APP-107` | Meera Joshi | 29 | 0 | 10,000 | $\infty$ | 710 | UNEMPLOYED | 0 | **REJECTED_INVALID** | NONE | 0.00 | Edge Case: Zero income detected. |
| `APP-108` | Vikram Batra | 38 | 110,000 | 28,000 | 25.5% | 610 | SALARIED | 0 | **REJECTED** | NONE | 0.00 | Credit score below risk threshold ($610 < 650$). |
| `APP-109` | Ananya Roy | 27 | 95,000 | 21,000 | 22.1% | 790 | SALARIED | 4 | **REJECTED** | NONE | 0.00 | Active loans overleveraged ($4 \ge 3$). |
| `APP-110` | Suresh Raina | 33 | 78,000 | 24,000 | 30.8% | 730 | SALARIED | 1 | **APPROVED** | STANDARD_HOME_SECURE | 9.10 | Standard credit tier approval. |

---

## 2. Captured Console Output

```text
=========================================================================================
                  RETAIL BANKING LOAN PRE-SCREENING ELIGIBILITY ENGINE                  
=========================================================================================

APP ID     | APPLICANT NAME   | DECISION       | LOAN PRODUCT               | RATE(%)  | UNDERWRITING RATIONALE
-------------------------------------------------------------------------------------------------------------------------
APP-101    | Arun Kumar       | APPROVED       | PRIME_SUPER_EXPRESS        | 8.25     | Excellent credit profile; eligible for lowest risk rate.
APP-102    | Priya Nair       | APPROVED       | STANDARD_HOME_SECURE       | 9.10     | Strong credit profile; standard tier approval.
APP-103    | Karthik Raja     | REJECTED       | NONE                       | 0.00     | Age outside acceptable 21-60 band
APP-104    | Sneha Patel      | REJECTED       | NONE                       | 0.00     | EMI ratio 64.4% exceeds 50% ceiling
APP-105    | Deepak Verma     | APPROVED       | SUBPRIME_CREDIT_BUILDER    | 11.50    | Fair credit profile; approved with premium rate loading.
APP-106    | Rohan Gupta      | REJECTED       | NONE                       | 0.00     | Age outside acceptable 21-60 band
APP-107    | Meera Joshi      | REJECTED_INVALID | NONE                     | 0.00     | Edge Case Validation: Negative age, zero income, or credit score out of range [300-900]
APP-108    | Vikram Batra     | REJECTED       | NONE                       | 0.00     | Credit score below minimum underwriting floor (< 650).
APP-109    | Ananya Roy       | REJECTED       | NONE                       | 0.00     | Applicant has reached active loans threshold (>= 3)
APP-110    | Suresh Raina     | APPROVED       | STANDARD_HOME_SECURE       | 9.10     | Strong credit profile; standard tier approval.
-------------------------------------------------------------------------------------------------------------------------
```
