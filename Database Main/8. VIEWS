#############################
	-- VIEW SUSPICIONS
#############################
use main;
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
          -- EMPLOYEES--
########################################
CREATE VIEW vw_employee_ordered_position AS
SELECT 
    e.emp_id AS "Employee ID",
    e.emp_fullname AS "Full Name",
    e.emp_sex AS "Gender",
    e.emp_dob AS "Date of Birth",
    e.emp_phone_num AS "Phone Number",
    e.emp_email AS "Email",
    e.emp_address AS "Address",
    CONCAT(FORMAT(e.emp_salary, 0), ' VND') AS "Salary",
    b.branch_name AS "Branch",
    p.emp_position_name AS "Position",
    e.emp_join_date AS "Join Date"
FROM 
    EMPLOYEES e
JOIN 
    BRANCHES b ON e.branch_id = b.branch_id
JOIN 
    EMPLOYEE_POSITIONS p ON e.emp_position_id = p.emp_position_id
ORDER BY 
    FIELD(b.branch_name, 'HN', 'HCM', 'ĐN', 'HP', 'QN'),  -- Sắp xếp theo chi nhánh
    FIELD(p.emp_position_name, 'CEO', 'Manager', 'Auditor', 'Teller'),  -- Sắp xếp theo cấp bậc (bỏ Director)
    RIGHT(e.emp_id, 6);  -- Sắp xếp theo 4 số cuối của ID nhân viên


CREATE VIEW vw_employees_ordered_branch AS
SELECT 
    e.emp_id AS "Employee ID",
    e.emp_fullname AS "Full Name",
    e.emp_sex AS "Gender",
    e.emp_dob AS "Date of Birth",
    e.emp_phone_num AS "Phone Number",
    e.emp_email AS "Email",
    e.emp_address AS "Address",
    CONCAT(FORMAT(e.emp_salary, 0), ' VND') AS "Salary",
    b.branch_name AS "Branch",
    p.emp_position_name AS "Position",
    e.emp_join_date AS "Join Date"
FROM 
    EMPLOYEES e
INNER JOIN 
    BRANCHES b ON e.branch_id = b.branch_id
INNER JOIN 
    EMPLOYEE_POSITIONS p ON e.emp_position_id = p.emp_position_id
ORDER BY 
    CASE 
        WHEN e.branch_id = 'HN' THEN 1
        WHEN e.branch_id = 'HCM' THEN 2
        WHEN e.branch_id = 'ĐN' THEN 3
        WHEN e.branch_id = 'HP' THEN 4
        WHEN e.branch_id = 'QN' THEN 5
        ELSE 6
    END,
    CASE 
        WHEN e.emp_position_id = 'C' THEN 1
        WHEN e.emp_position_id = 'M' THEN 2
        WHEN e.emp_position_id = 'T' THEN 3
        WHEN e.emp_position_id = 'A' THEN 4
        ELSE 5
    END,
    RIGHT(e.emp_id,6);
