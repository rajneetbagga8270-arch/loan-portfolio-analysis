-- Query 1: Total number of loans
-- Counts the total volume of loan applications processed
SELECT 
    COUNT(id) AS total_loans
FROM financial_loan;


-- Query 2: Total loan amount
-- Calculates the total funded/disbursed capital across the entire portfolio
SELECT 
    SUM(loan_amount) AS total_funded_amount
FROM financial_loan;


-- Query 3: Average loan amount
-- Determines the typical loan size issued to borrowers
SELECT 
    AVG(loan_amount) AS average_loan_amount
FROM financial_loan;


-- Query 4: Minimum loan amount
-- Identifies the smallest individual loan disbursed
SELECT 
    MIN(loan_amount) AS min_loan_amount
FROM financial_loan;


-- Query 5: Maximum loan amount
-- Identifies the largest individual loan disbursed
SELECT 
    MAX(loan_amount) AS max_loan_amount
FROM financial_loan;


-- Query 6: Number of loans by loan status
-- Breaks down loan distribution across statuses (Fully Paid, Current, Charged Off)
SELECT 
    loan_status,
    COUNT(id) AS loan_count
FROM financial_loan
GROUP BY loan_status
ORDER BY loan_count DESC;


-- Query 7: Good loans vs. Bad loans
-- Classifies performing loans ('Fully Paid', 'Current') vs non-performing ('Charged Off')
SELECT 
    CASE 
        WHEN loan_status IN ('Fully Paid', 'Current') THEN 'Good Loan'
        WHEN loan_status = 'Charged Off' THEN 'Bad Loan'
        ELSE 'Other'
    END AS loan_category,
    COUNT(id) AS total_loans,
    SUM(loan_amount) AS total_amount
FROM financial_loan
GROUP BY 
    CASE 
        WHEN loan_status IN ('Fully Paid', 'Current') THEN 'Good Loan'
        WHEN loan_status = 'Charged Off' THEN 'Bad Loan'
        ELSE 'Other'
    END;


-- Query 8: Grade-wise loan count
-- Evaluates portfolio credit quality by counting loans across credit risk grades (A through G)
SELECT 
    grade,
    COUNT(id) AS total_loans
FROM financial_loan
GROUP BY grade
ORDER BY grade ASC;


-- Query 9: State-wise loan count
-- Analyzes geographic exposure by counting loans issued across each state
SELECT 
    address_state,
    COUNT(id) AS total_loans
FROM financial_loan
GROUP BY address_state
ORDER BY total_loans DESC;


-- Query 10: Average interest rate
-- Measures portfolio yield by calculating the average borrower interest rate
SELECT 
    AVG(int_rate) * 100 AS average_interest_rate_percentage
FROM financial_loan;



















