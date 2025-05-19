DELIMITER //

CREATE PROCEDURE AddTransaction(
    IN p_trans_type_id VARCHAR(3),
    IN p_cus_account_id VARCHAR(17),
    IN p_related_cus_account_id VARCHAR(17),
    IN p_trans_amount INT,
    IN p_direction ENUM('Debit', 'Credit'),
    IN p_trans_status ENUM('Failed', 'Successful'),
    IN p_trans_time DATETIME,
    IN p_last_updated DATETIME,
    OUT p_result VARCHAR(255),
    OUT p_error_code VARCHAR(20)
)
BEGIN
    -- Labeled block for controlled exit
    proc: BEGIN

        -- Handle SQL exceptions
        DECLARE EXIT HANDLER FOR SQLEXCEPTION 
        BEGIN
            SET p_result = 'Error: System error while adding transaction';
            SET p_error_code = 'SYSTEM_ERROR';
        END;

        -- Initialize output
        SET p_result = '';
        SET p_error_code = '';

        -- Set default for status if NULL
        IF p_trans_status IS NULL THEN
            SET p_trans_status = 'Successful';
        END IF;

        -- Validate required fields
        IF p_trans_type_id IS NULL OR 
           p_cus_account_id IS NULL OR 
           p_trans_amount IS NULL OR 
           p_direction IS NULL THEN
            SET p_result = 'Error: Missing required fields (trans_type_id, cus_account_id, trans_amount, direction)';
            SET p_error_code = 'MISSING_FIELDS';
            LEAVE proc;
        END IF;

        -- Insert transaction
        INSERT INTO TRANSACTIONS (
            trans_type_id, cus_account_id, related_cus_account_id,
            trans_amount, direction, trans_status, 
            trans_time, last_updated
        ) VALUES (
            p_trans_type_id, p_cus_account_id, p_related_cus_account_id,
            p_trans_amount, p_direction, p_trans_status, 
            p_trans_time, p_last_updated
        );

        -- Set success output
        SET p_result = CONCAT('Transaction added successfully. ID: ', LAST_INSERT_ID());
        SET p_error_code = 'SUCCESS';

    END proc;
END //

DELIMITER ;
-- Khai báo biến để nhận kết quả
SET @result = '';
SET @error_code = '';

-- Gọi thủ tục
CALL AddTransaction(
    'TRF',                          -- p_trans_type_id
    'DTNBS250000001',              -- p_cus_account_id
    'DTNBC240000001',              -- p_related_cus_account_id
    1501,                          -- p_trans_amount
    'Debit',                       -- p_direction
    'Successful',                  -- p_trans_status
    '2025-05-17 16:00:00',         -- p_trans_time
    '2025-05-17 16:00:00',         -- p_last_updated
    @result,                       -- OUT p_result
    @error_code                    -- OUT p_error_code
);
-- select * from transactions;
use main;
-- -- Xem kết quả
-- SELECT @result, @error_code;
SET @result = '', @code = '';
DROP PROCEDURE IF EXISTS add_customer_account;
DELIMITER //

CREATE PROCEDURE add_customer_account(
    IN p_cus_id VARCHAR(17),
    IN p_cus_account_type_id VARCHAR(2),
    OUT p_result VARCHAR(255),
    OUT p_error_code VARCHAR(20)
)
proc: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SET p_result = 'System error occurred';
        SET p_error_code = 'SYSTEM_ERROR';
    END;

    SET p_result = '';
    SET p_error_code = '';

    -- Kiểm tra cus_id tồn tại
    IF NOT EXISTS (SELECT 1 FROM CUSTOMERS WHERE cus_id = p_cus_id) THEN
        SET p_result = 'Error: cus_id does not exist';
        SET p_error_code = 'INVALID_CUS_ID';
        LEAVE proc;
    END IF;

    -- Kiểm tra account_type_id tồn tại
    IF NOT EXISTS (SELECT 1 FROM CUSTOMER_ACCOUNT_TYPES WHERE cus_account_type_id = p_cus_account_type_id) THEN
        SET p_result = 'Error: account type does not exist';
        SET p_error_code = 'INVALID_ACCOUNT_TYPE';
        LEAVE proc;
    END IF;

    START TRANSACTION;

    -- Thêm tài khoản (không cần truyền cus_account_id)
    INSERT INTO CUSTOMER_ACCOUNTS (
        cus_id,
        cus_account_type_id
    ) VALUES (
        p_cus_id,
        p_cus_account_type_id
    );

    COMMIT;

    SET p_result = 'Account added successfully';
    SET p_error_code = 'SUCCESS';
END //

DELIMITER ;

select * from customers;
CALL add_customer_account(
	'DTNBDN130000001', 'F',    
    @result,                       -- OUT p_result
    @error_code  
);
SELECT @result, @error_code;

select * from customer_accounts where cus_id = 'DTNBDN130000001';
-- Procedure lấy thông tin account của khách hàng
DELIMITER //
CREATE PROCEDURE GetAccountDetailsById(IN p_account_id VARCHAR(20))
BEGIN
    SELECT 
        ca.*, 
        cat.cus_account_type_name, 
        COALESCE(sa.saving_acc_balance, ck.check_acc_balance, fd.deposit_amount) AS balance,
        COALESCE(sa.interest_rate_id, ck.interest_rate_id, fd.interest_rate_id) AS interest_rate_id,
        ir.interest_rate_val,
        ca.opening_date
    FROM CUSTOMER_ACCOUNTS ca
    LEFT JOIN CUSTOMER_ACCOUNT_TYPES cat ON ca.cus_account_type_id = cat.cus_account_type_id
    LEFT JOIN SAVING_ACCOUNTS sa ON ca.cus_account_id = sa.cus_account_id
    LEFT JOIN CHECK_ACCOUNTS ck ON ca.cus_account_id = ck.cus_account_id
    LEFT JOIN FIXED_DEPOSIT_ACCOUNTS fd ON ca.cus_account_id = fd.cus_account_id
    LEFT JOIN INTEREST_RATES ir ON ir.interest_rate_id = COALESCE(sa.interest_rate_id, ck.interest_rate_id, fd.interest_rate_id)
    WHERE ca.cus_account_id = p_account_id;
END //

DELIMITER ;
call GetAccountDetailsById('DTNBC120000001');

-- View hiện thông tin (general) khách hàng và tài khoản 
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

select * from v_customer_summary;

-------- Procedure và View cho Employees-----------------
USE MAIN;

CREATE OR REPLACE VIEW v_employee_summary AS
SELECT 
    e.emp_id,
    e.emp_fullname,
    e.emp_phone_num,
    e.emp_email,
    e.branch_id,
    b.branch_name,
    ep.emp_position_name
FROM EMPLOYEES e
LEFT JOIN BRANCHES b ON e.branch_id = b.branch_id
LEFT JOIN EMPLOYEE_POSITIONS ep ON e.emp_position_id = ep.emp_position_id;

select * from v_employee_summary;


DELIMITER $$
CREATE PROCEDURE GetEmployeeDetailsById(IN p_emp_id VARCHAR(20))
BEGIN
    SELECT 
        e.*, 
        b.branch_name,
        ep.emp_position_name
    FROM EMPLOYEES e
    LEFT JOIN BRANCHES b ON e.branch_id = b.branch_id
    LEFT JOIN EMPLOYEE_POSITIONS ep ON e.emp_position_id = ep.emp_position_id
    Where e.emp_id = p_emp_id;
END $$
DELIMITER ;

call GetEmployeeDetailsById('DNT190001');
call GetEmployeeDetailsById('DNT200001');

SELECT s.suspicion_id, t.trans_id, fp.fraud_pattern_name, 
                       s.detected_time, s.severity_level, s.suspicion_status,
                       CONCAT(c.cus_first_name, ' ', c.cus_last_name) as customer_name,
                       ca.cus_account_id, t.trans_amount
                FROM SUSPICIONS s
                JOIN TRANSACTIONS t ON s.trans_id = t.trans_id
                JOIN FRAUD_PATTERNS fp ON s.fraud_pattern_id = fp.fraud_pattern_id
                JOIN CUSTOMER_ACCOUNTS ca ON t.cus_account_id = ca.cus_account_id
                JOIN CUSTOMERS c ON ca.cus_id = c.cus_id
                WHERE s.suspicion_status != 'Resolved'
                ORDER BY
                    CASE s.severity_level
                        WHEN 'High' THEN 1
                        WHEN 'Medium' THEN 2
                        WHEN 'Low' THEN 3
                        ELSE 4
                    END,
                    s.detected_time DESC
                LIMIT 1000;
                
                
SELECT ca.cus_account_id, 
                ca.cus_account_status, 
                cat.cus_account_type_name,
                ca.cus_account_type_id,
                COALESCE(sa.saving_acc_balance, ck.check_acc_balance, fd.deposit_amount) as balance,
                ca.opening_date
            FROM CUSTOMER_ACCOUNTS ca
            LEFT JOIN CUSTOMER_ACCOUNT_TYPES cat ON ca.cus_account_type_id = cat.cus_account_type_id
            LEFT JOIN SAVING_ACCOUNTS sa ON ca.cus_account_id = sa.cus_account_id
            LEFT JOIN CHECK_ACCOUNTS ck ON ca.cus_account_id = ck.cus_account_id
            LEFT JOIN FIXED_DEPOSIT_ACCOUNTS fd ON ca.cus_account_id = fd.cus_account_id
            WHERE ca.cus_id = "DTNBDN130000001";
            
SELECT s.suspicion_id, t.trans_id, fp.fraud_pattern_name, 
                       s.detected_time, s.severity_level, s.suspicion_status,
                       CONCAT(c.cus_first_name, ' ', c.cus_last_name) as customer_name,
                       ca.cus_account_id, t.trans_amount
                FROM SUSPICIONS s
                JOIN TRANSACTIONS t ON s.trans_id = t.trans_id
                JOIN FRAUD_PATTERNS fp ON s.fraud_pattern_id = fp.fraud_pattern_id
                JOIN CUSTOMER_ACCOUNTS ca ON t.cus_account_id = ca.cus_account_id
                JOIN CUSTOMERS c ON ca.cus_id = c.cus_id
                WHERE s.suspicion_status != 'Resolved'
                ORDER BY
                    CASE s.severity_level
                        WHEN 'High' THEN 1
                        WHEN 'Medium' THEN 2
                        WHEN 'Low' THEN 3
                        ELSE 4
                    END,
                    s.detected_time DESC
                LIMIT 1000
