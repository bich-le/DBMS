use main;
#############################
	-- VIEW SUSPICIONS--
#############################

SELECT
    s.suspicion_id,
    t.trans_id,
    CONCAT(c.cus_last_name, ' ', c.cus_first_name) AS customer_name,
    ca.cus_account_id,
    fp.fraud_pattern_name,
    s.severity_level,
    t.trans_amount,
    t.trans_status,
    s.suspicion_status,
	s.detected_time
FROM SUSPICIONS s
JOIN TRANSACTIONS t ON s.trans_id = t.trans_id
LEFT JOIN CUSTOMER_ACCOUNTS ca ON t.cus_account_id = ca.cus_account_id
LEFT JOIN CUSTOMERS c ON ca.cus_id = c.cus_id
JOIN FRAUD_PATTERNS fp ON s.fraud_pattern_id = fp.fraud_pattern_id
WHERE s.suspicion_status != 'Resolved'
ORDER BY
    CASE s.severity_level
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
        ELSE 4
    END,
    s.suspicion_id DESC
LIMIT 0, 1000;

################################
       -- ACCOUNTS --
#################################
 CREATE OR REPLACE VIEW saving_accounts_view AS
    SELECT 
      cus_account_id AS 'Account ID',
      interest_rate_id AS 'Interest Rate ID',
      CONCAT(FORMAT(saving_acc_balance, 0), ' VND') AS 'Balance'
    FROM SAVING_ACCOUNTS;
CREATE OR REPLACE VIEW check_accounts_view AS
    SELECT 
      cus_account_id AS 'Account ID',
      interest_rate_id AS 'Interest Rate ID',
      CONCAT(FORMAT(check_acc_balance, 0), ' VND') AS 'Balance',
      CONCAT(FORMAT(transfer_limit, 0), ' VND') AS 'Transfer Limit',
      CONCAT(FORMAT(daily_transfer_limit, 0), ' VND') AS 'Daily Transfer Limit'
    FROM CHECK_ACCOUNTS;
CREATE OR REPLACE VIEW fixed_deposit_accounts_view AS
    SELECT 
      cus_account_id AS 'Account ID',
      interest_rate_id AS 'Interest Rate ID',
      CONCAT(FORMAT(deposit_amount, 0), ' VND') AS 'Deposit Amount',
      deposit_date AS 'Deposit Date',
      maturity_date AS 'Maturity Date'
    FROM FIXED_DEPOSIT_ACCOUNTS;
########################################
          -- ViewCustomer--
########################################
--Displays general customer information along with their account summary.
CREATE OR REPLACE VIEW v_customer_summary AS
SELECT 
    c.cus_id,
    CONCAT(c.cus_first_name, ' ', c.cus_last_name) AS customer_name,
    c.cus_phone_num,
    c.cus_email,
    b.branch_name,
    COUNT(ca.cus_account_id) AS account_count,
    GROUP_CONCAT(cat.cus_account_type_name SEPARATOR ', ') AS account_types
FROM CUSTOMERS c
LEFT JOIN BRANCHES b ON c.branch_id = b.branch_id
LEFT JOIN CUSTOMER_ACCOUNTS ca ON c.cus_id = ca.cus_id
LEFT JOIN CUSTOMER_ACCOUNT_TYPES cat ON ca.cus_account_type_id = cat.cus_account_type_id
GROUP BY c.cus_id;

########################################
          -- ViewEmployees--
########################################
--Provides basic information for all employees, including their branch and position.
CREATE OR REPLACE VIEW v_employee_summary AS
SELECT 
    e.*,
    b.branch_name,
    ep.emp_position_name
FROM EMPLOYEES e
LEFT JOIN BRANCHES b ON e.branch_id = b.branch_id
LEFT JOIN EMPLOYEE_POSITIONS ep ON e.emp_position_id = ep.emp_position_id;

