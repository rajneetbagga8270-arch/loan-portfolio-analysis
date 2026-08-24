
CREATE DATABASE loan_data;
USE loan_data;

-- 1. Total number of loans
SELECT COUNT(*) AS total_loans
FROM loan_data;
-- Business insight:
-- This establishes the overall size of the loan portfolio and acts as the base metric for calculating other portfolio ratios.

-- 2. Total loan amount requested
SELECT
    SUM(loan_amnt) AS total_loan_amount
FROM loan_data;
-- Business insight:
-- Shows the total amount customers requested. This helps management understand the overall demand for credit.

-- 3. Total amount funded
SELECT
    SUM(funded_amnt) AS total_funded_amount
FROM loan_data;
-- Measures the actual capital deployed by the lender rather than merely the amount requested.

-- 4. Average loan amount
SELECT
    ROUND(AVG(loan_amnt), 2) AS average_loan_amount
FROM loan_data;
-- Helps determine the typical customer borrowing requirement and can support future loan-product design.

-- 5. Average funded amount vs requested amount
SELECT
    ROUND(AVG(loan_amnt), 2) AS avg_requested,
    ROUND(AVG(funded_amnt), 2) AS avg_funded
FROM loan_data;
-- If funded amounts are consistently below requested amounts, it may indicate underwriting limits or partial funding.

-- 6. Loan status distribution
SELECT
    loan_status,
    COUNT(*) AS loan_count
FROM loan_data
GROUP BY loan_status
ORDER BY loan_count DESC;
-- Shows whether the portfolio is primarily Current, Fully Paid, Late, Charged Off, or Defaulted.

-- 7. Loan status + funded amount
SELECT
    loan_status,
    COUNT(*) AS loan_count,
    SUM(funded_amnt) AS total_funded
FROM loan_data
GROUP BY loan_status
ORDER BY total_funded DESC;
-- Loan count alone can be misleading. This tells management where the actual money is concentrated.

-- 8. Percentage of portfolio by loan status
SELECT
    loan_status,
    COUNT(*) AS loan_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),2) AS portfolio_percentage
FROM loan_data
GROUP BY loan_status
ORDER BY portfolio_percentage DESC;
-- Allows management to quickly understand the composition of the portfolio and identify statuses requiring attention.

-- RISK ANALYSIS
-- 9. Good loans vs bad loans
SELECT
    CASE
        WHEN loan_status IN
            ('Charged Off', 'Default', 'Late (31-120 days)')
        THEN 'Bad Loan'
        ELSE 'Good Loan'
    END AS loan_category,
    
    COUNT(*) AS loan_count,
    SUM(funded_amnt) AS funded_amount
FROM loan_data
GROUP BY loan_category;
-- It tells the lender how much of its portfolio is performing normally versus showing serious repayment risk.

-- 1-. Good vs bad loan percentage
WITH loan_categories AS (
    SELECT
        CASE
            WHEN loan_status IN
                ('Charged Off', 'Default', 'Late (31-120 days)')
            THEN 'Bad Loan'
            ELSE 'Good Loan'
        END AS loan_category
    FROM loan_data
)

SELECT
    loan_category,
    COUNT(*) AS loan_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),2) AS percentage
FROM loan_categories
GROUP BY loan_category;
-- This gives management a simple portfolio health KPI that can go directly onto your Power BI dashboard.

-- 11. Bad-loan rate by grade
SELECT
    grade,
    COUNT(*) AS total_loans,

    SUM(
        CASE
            WHEN loan_status IN
                ('Charged Off', 'Default', 'Late (31-120 days)')
            THEN 1
            ELSE 0
        END
    ) AS bad_loans,

    ROUND(100.0 *SUM
    (
            CASE
                WHEN loan_status IN
                    ('Charged Off', 'Default', 'Late (31-120 days)')
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),2) AS bad_loan_rate

FROM loan_data
GROUP BY grade
ORDER BY bad_loan_rate DESC;
-- This can help the lender decide whether higher-risk grades require stricter underwriting or higher pricing.

-- 12. Charged-off rate by grade
SELECT
    grade,
    COUNT(*) AS total_loans,

    SUM(
        CASE
            WHEN loan_status = 'Charged Off'
            THEN 1
            ELSE 0
        END
    ) AS charged_off_loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN loan_status = 'Charged Off'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS charged_off_rate

FROM loan_data
GROUP BY grade
ORDER BY charged_off_rate DESC;
-- Shows which grades are most exposed to actual loan losses.

-- 13. Portfolio by grade
SELECT
    grade,
    COUNT(*) AS loan_count,
    SUM(funded_amnt) AS funded_amount,
    ROUND(AVG(loan_amnt), 2) AS average_loan
FROM loan_data
GROUP BY grade
ORDER BY funded_amount DESC;
-- Shows where the lender's capital is concentrated across credit-quality segments.
-- In your dataset, Grade C has the largest number of loans and the highest funded amount, making it particularly important for portfolio monitoring.


-- 14. Sub-grade analysis
SELECT
    sub_grade,
    COUNT(*) AS loan_count,
    SUM(funded_amnt) AS funded_amount,
    ROUND(AVG(loan_amnt), 2) AS average_loan
FROM loan_data
GROUP BY sub_grade
ORDER BY funded_amount DESC;
-- Sub-grade analysis provides more granular risk segmentation than broad A–G grades.

-- 15. Top 10 sub-grades by funded amount
SELECT
    sub_grade,
    SUM(funded_amnt) AS funded_amount
FROM loan_data
GROUP BY sub_grade
ORDER BY funded_amount DESC
LIMIT 10;
-- Identifies the specific credit segments where the lender has the greatest financial exposure.

-- Interest Rate Analysis
-- 16. Average interest rate by grade
SELECT
    grade,
    ROUND(AVG(int_rate), 2) AS average_interest_rate
FROM loan_data
GROUP BY grade
ORDER BY average_interest_rate;
-- Shows how loan pricing changes with credit risk.
-- You should expect riskier grades to generally carry higher interest rates.


-- 17. Interest rate by loan status
SELECT
    loan_status,
    ROUND(AVG(int_rate), 2) AS average_interest_rate,
    ROUND(AVG(loan_amnt), 2) AS average_loan_amount
FROM loan_data
GROUP BY loan_status
ORDER BY average_interest_rate DESC;
-- Allows you to investigate whether loans experiencing repayment problems were originally priced at higher rates.

-- 18. 36 vs 60 month loans
SELECT
    term,
    COUNT(*) AS loan_count,
    SUM(funded_amnt) AS funded_amount,
    ROUND(AVG(int_rate), 2) AS average_interest_rate
FROM loan_data
GROUP BY term
ORDER BY term;
-- Shows how customers choose between short- and long-term borrowing and whether longer-term loans represent a significant portion of the lender's exposure.

-- 19. Bad-loan rate by term
SELECT
    term,
    COUNT(*) AS total_loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN loan_status IN
                    ('Charged Off', 'Default', 'Late (31-120 days)')
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS bad_loan_rate

FROM loan_data
GROUP BY term;
-- Helps determine whether loan duration is associated with increased repayment risk.


-- 20. Loan performance by verification status
SELECT
    verification_status,
    COUNT(*) AS loan_count,
    SUM(funded_amnt) AS funded_amount
FROM loan_data
GROUP BY verification_status
ORDER BY funded_amount DESC;
-- Shows how much capital is being deployed to verified versus non-verified borrowers.


-- 21. Bad-loan rate by verification status
SELECT
    verification_status,
    COUNT(*) AS total_loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN loan_status IN
                    ('Charged Off', 'Default', 'Late (31-120 days)')
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS bad_loan_rate

FROM loan_data
GROUP BY verification_status
ORDER BY bad_loan_rate DESC;
-- Tests whether borrower verification is associated with better repayment performance.
-- This is a genuine business question, rather than just a descriptive query.

-- 22. State-wise portfolio
SELECT
    addr_state,
    COUNT(*) AS loan_count,
    SUM(funded_amnt) AS funded_amount,
    ROUND(AVG(loan_amnt), 2) AS average_loan
FROM loan_data
GROUP BY addr_state
ORDER BY funded_amount DESC;
-- Shows where the lender's customer base and capital exposure are geographically concentrated.

-- 23. Top 10 states by funded amount
SELECT
    addr_state,
    SUM(funded_amnt) AS funded_amount
FROM loan_data
GROUP BY addr_state
ORDER BY funded_amount DESC
LIMIT 10;
-- Helps identify the most important geographic markets for the lending business.
-- Your data shows California as the largest state by funded amount, followed by New York and Texas.

-- 24. Bad-loan rate by state
SELECT
    addr_state,
    COUNT(*) AS total_loans,

    ROUND(100.0 * SUM(
            CASE
                WHEN loan_status IN
                    ('Charged Off', 'Default', 'Late (31-120 days)')
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),2) AS bad_loan_rate

FROM loan_data
GROUP BY addr_state
HAVING COUNT(*) >= 50
ORDER BY bad_loan_rate DESC;
-- Identifies geographic markets with unusually high repayment risk.
-- The HAVING COUNT(*) >= 50 prevents tiny states from producing misleading risk percentages.


-- 25. Loans issued by month
SELECT
    issue_d,
    COUNT(*) AS loan_count,
    SUM(funded_amnt) AS funded_amount
FROM loan_data
GROUP BY issue_d
ORDER BY issue_d;
-- Shows how loan demand and capital deployment change over time.


-- 26. Monthly funded amount
SELECT
    YEAR(issue_d) AS issue_year,
    MONTH(issue_d) AS issue_month,
    SUM(funded_amnt) AS funded_amount
FROM loan_data
GROUP BY
    YEAR(issue_d),
    MONTH(issue_d)
ORDER BY
    issue_year,
    issue_month;
-- Useful for identifying growth trends, seasonality and periods of unusually high lending activity.

-- 27. Find grades above the average portfolio funding
WITH grade_summary AS (

    SELECT
        grade,
        SUM(funded_amnt) AS total_funded
    FROM loan_data
    GROUP BY grade

)

SELECT
    grade,
    total_funded
FROM grade_summary
WHERE total_funded >
(
    SELECT AVG(total_funded)
    FROM grade_summary
)
ORDER BY total_funded DESC;
-- Identifies credit grades with disproportionately high capital exposure.

-- 28. Rank grades by funded amount
SELECT
    grade,
    SUM(funded_amnt) AS total_funded,

    RANK() OVER (
        ORDER BY SUM(funded_amnt) DESC
    ) AS funding_rank

FROM loan_data
GROUP BY grade;
-- Creates a clear ranking of credit grades based on financial exposure.


-- 29. Percentage of total funding by grade
SELECT
    grade,
    SUM(funded_amnt) AS total_funded,

    ROUND(
        100.0 * SUM(funded_amnt) /
        SUM(SUM(funded_amnt)) OVER (),
        2
    ) AS funding_percentage

FROM loan_data
GROUP BY grade
ORDER BY funding_percentage DESC;
-- Shows how much of the entire portfolio is concentrated in each grade.

-- 30. Grade-wise risk and financial exposure
SELECT
    grade,

    COUNT(*) AS total_loans,

    SUM(funded_amnt) AS total_funded,

    ROUND(AVG(int_rate), 2) AS avg_interest_rate,

    SUM(
        CASE
            WHEN loan_status IN
                ('Charged Off', 'Default', 'Late (31-120 days)')
            THEN 1
            ELSE 0
        END
    ) AS bad_loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN loan_status IN
                    ('Charged Off', 'Default', 'Late (31-120 days)')
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS bad_loan_rate

FROM loan_data
GROUP BY grade
ORDER BY total_funded DESC;
-- This is the core business analysis of project.
-- "Which credit grades have the greatest financial exposure, and what level of repayment risk comes with that exposure?"























