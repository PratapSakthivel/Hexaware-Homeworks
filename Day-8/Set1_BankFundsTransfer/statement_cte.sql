-- ============================================================================
-- Day 8: CTEs, Window Functions and Transactions – MySQL 8.4 LTS
-- Set 1: Bank Funds Transfer
-- File: statement_cte.sql
-- Description: Task 4 – Monthly Account Statement using CTEs, ROW_NUMBER(),
--              and LAG() to display chronological transactions alongside
--              their preceding balance.
-- ============================================================================

USE bank_funds_db;

-- ----------------------------------------------------------------------------
-- Populate Additional Ledger History for Rich Monthly Statement Analysis
-- ----------------------------------------------------------------------------
INSERT INTO account_ledger (account_id, transaction_id, entry_type, amount, post_balance, description, entry_date) VALUES
(1, NULL, 'CREDIT', 15000.00, 51000.00, 'Salary Credit - Employer Payroll', '2026-10-15 10:00:00'),
(1, NULL, 'DEBIT',  2500.00,  48500.00, 'Utility Bill - Electricity Board', '2026-10-18 14:30:00'),
(1, NULL, 'DEBIT',  8200.00,  40300.00, 'E-Commerce Merchant Purchase', '2026-10-22 19:15:00'),
(1, NULL, 'CREDIT', 1200.00,  41500.00, 'Cashback Refund - Festive Promo', '2026-10-25 11:20:00'),
(1, NULL, 'DEBIT',  5500.00,  36000.00, 'ATM Cash Withdrawal', '2026-10-28 17:45:00'),

(2, NULL, 'DEBIT',  1200.00,  23800.00, 'Grocery Supermarket Checkout', '2026-10-12 12:15:00'),
(2, NULL, 'DEBIT',  4500.00,  19300.00, 'Insurance Policy Premium Debit', '2026-10-16 08:30:00'),
(2, NULL, 'CREDIT', 8000.00,  27300.00, 'Client Consulting Inflow', '2026-10-24 16:00:00');

-- ----------------------------------------------------------------------------
-- Task 4 Query: Monthly Statement using CTE, ROW_NUMBER() and LAG()
-- ----------------------------------------------------------------------------

-- CTE Statement for Account 1 (Aditya Sharma)
WITH MonthlyLedgerCTE AS (
    SELECT 
        l.ledger_id,
        l.account_id,
        a.account_number,
        a.customer_name,
        l.entry_date,
        l.entry_type,
        l.amount,
        l.post_balance,
        l.description,
        -- Generate strict chronological sequence number for this statement period
        ROW_NUMBER() OVER (
            PARTITION BY l.account_id 
            ORDER BY l.entry_date ASC, l.ledger_id ASC
        ) AS txn_seq_num,
        -- Retrieve the post_balance of the immediate preceding transaction
        LAG(l.post_balance, 1) OVER (
            PARTITION BY l.account_id 
            ORDER BY l.entry_date ASC, l.ledger_id ASC
        ) AS previous_balance
    FROM account_ledger l
    JOIN accounts a ON l.account_id = a.account_id
    WHERE l.account_id = 1
      AND l.entry_date >= '2026-10-01 00:00:00'
      AND l.entry_date <= '2026-10-31 23:59:59'
)
SELECT 
    txn_seq_num,
    entry_date,
    description,
    entry_type,
    amount,
    -- If opening transaction, previous balance is derived from post_balance and current amount
    COALESCE(
        previous_balance, 
        CASE 
            WHEN entry_type = 'CREDIT' THEN post_balance - amount 
            ELSE post_balance + amount 
        END
    ) AS opening_balance_before_txn,
    post_balance AS closing_balance_after_txn,
    -- Audit check verifying mathematical consistency: Opening +/- Amount = Closing
    CASE 
        WHEN entry_type = 'CREDIT' AND (COALESCE(previous_balance, post_balance - amount) + amount = post_balance) THEN 'VERIFIED_OK'
        WHEN entry_type = 'DEBIT'  AND (COALESCE(previous_balance, post_balance + amount) - amount = post_balance) THEN 'VERIFIED_OK'
        ELSE 'MISMATCH_FLAGGED'
    END AS ledger_audit_status
FROM MonthlyLedgerCTE
ORDER BY txn_seq_num ASC;


-- ----------------------------------------------------------------------------
-- Bonus / Comprehensive: Multi-Account Statement Overview CTE
-- ----------------------------------------------------------------------------
WITH AllAccountsStatementCTE AS (
    SELECT 
        a.account_number,
        a.customer_name,
        l.entry_date,
        l.entry_type,
        l.amount,
        l.description,
        l.post_balance,
        ROW_NUMBER() OVER (PARTITION BY a.account_id ORDER BY l.entry_date ASC, l.ledger_id ASC) AS seq,
        LAG(l.post_balance, 1) OVER (PARTITION BY a.account_id ORDER BY l.entry_date ASC, l.ledger_id ASC) AS prior_balance
    FROM account_ledger l
    JOIN accounts a ON l.account_id = a.account_id
)
SELECT 
    account_number,
    customer_name,
    seq,
    entry_date,
    description,
    entry_type,
    amount,
    COALESCE(prior_balance, post_balance - (CASE WHEN entry_type='CREDIT' THEN amount ELSE -amount END)) AS prior_balance,
    post_balance
FROM AllAccountsStatementCTE
ORDER BY account_number, seq;
