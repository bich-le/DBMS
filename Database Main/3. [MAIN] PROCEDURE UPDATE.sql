#################################################
        -- UPDATE TRANSACTIONS --
#################################################
DELIMITER //

CREATE PROCEDURE AddTransaction(
    IN p_trans_type_id VARCHAR(3),
    IN p_cus_account_id VARCHAR(17),
    IN p_related_cus_account_id VARCHAR(17),
    IN p_trans_amount INT,
    IN p_direction ENUM('Debit', 'Credit'),
    IN p_trans_status ENUM('Failed', 'Successful'),
    IN p_trans_error_code VARCHAR(10),
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
            trans_amount, direction, trans_status, trans_error_code,
            trans_time, last_updated
        ) VALUES (
            p_trans_type_id, p_cus_account_id, p_related_cus_account_id,
            p_trans_amount, p_direction, p_trans_status, p_trans_error_code,
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
#################################################
        -- UPDATE CUSTOMER ACCOUNTS --
#################################################
CREATE PROCEDURE update_customer_account(
    IN p_cus_account_id VARCHAR(17),
    IN p_account_type_id VARCHAR(2),
    IN p_balance BIGINT UNSIGNED,
    IN p_interest_rate_id TINYINT,
    IN p_transfer_limit INT UNSIGNED,
    IN p_daily_transfer_limit BIGINT UNSIGNED,
    IN p_deposit_amount BIGINT UNSIGNED,
    IN p_deposit_date DATE,
    IN p_maturity_date DATE,
    OUT p_result VARCHAR(255),
    OUT p_error_code VARCHAR(20)
)
update_proc: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET p_result = 'Error: System error while updating account';
        SET p_error_code = 'SYSTEM_ERROR';
    END;

    SET p_result = '';
    SET p_error_code = '';

    IF p_account_type_id = 'S' THEN
        UPDATE SAVING_ACCOUNTS
        SET saving_acc_balance = IFNULL(p_balance, saving_acc_balance),
            interest_rate_id = IFNULL(p_interest_rate_id, interest_rate_id)
        WHERE cus_account_id = p_cus_account_id;

    ELSEIF p_account_type_id = 'C' THEN
        UPDATE CHECK_ACCOUNTS
        SET check_acc_balance = IFNULL(p_balance, check_acc_balance),
            interest_rate_id = IFNULL(p_interest_rate_id, interest_rate_id),
            transfer_limit = IFNULL(p_transfer_limit, transfer_limit),
            daily_transfer_limit = IFNULL(p_daily_transfer_limit, daily_transfer_limit)
        WHERE cus_account_id = p_cus_account_id;

    ELSEIF p_account_type_id = 'F' THEN
        UPDATE FIXED_DEPOSIT_ACCOUNTS
        SET deposit_amount = IFNULL(p_deposit_amount, deposit_amount),
            interest_rate_id = IFNULL(p_interest_rate_id, interest_rate_id),
            deposit_date = IFNULL(p_deposit_date, deposit_date),
            maturity_date = IFNULL(p_maturity_date, maturity_date)
        WHERE cus_account_id = p_cus_account_id;

    ELSE
        SET p_result = 'Error: Invalid account type';
        SET p_error_code = 'INVALID_ACCOUNT_TYPE';
        LEAVE update_proc;
    END IF;

    IF ROW_COUNT() > 0 THEN
        SET p_result = 'Update successful';
        SET p_error_code = 'SUCCESS';
    ELSE
        SET p_result = 'No rows updated - check cus_account_id or all values NULL';
        SET p_error_code = 'NO_UPDATE';
    END IF;
END;
//
DELIMITER ;

-- Tạo biến đầu ra
-- SET @result = '';
-- SET @error_code = '';
-- -- Gọi thủ tục
-- CALL AddTransaction(
--     'TRF',                          -- p_trans_type_id
--     'DTNBS250000001',              -- p_cus_account_id
--     'DTNBC240000001',              -- p_related_cus_account_id
--     1501,                          -- p_trans_amount
--     'Debit',                       -- p_direction
--     'Successful',                  -- p_trans_status
--     NULL,                          -- p_trans_error_code
--     '2025-05-17 16:00:00',         -- p_trans_time
--     '2025-05-17 16:00:00',         -- p_last_updated
--     @result,                       -- OUT p_result
--     @error_code                    -- OUT p_error_code
-- );
-- select * from transactions;
-- -- Xem kết quả
-- SELECT @result, @error_code;

##################################################
        -- ADD CUSTOMER ACCOUNTS --
##################################################
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
-- select * from customers;
-- CALL add_customer_account(
-- 	'DTNBDN130000001', 'F',    
--     @result,                       -- OUT p_result
--     @error_code  
-- );
-- SELECT @result, @error_code;

-- select * from customer_accounts where cus_id = 'DTNBDN130000001';

##################################################
        -- GetAccountDetailsById --
##################################################
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

##################################################
        -- GetEmployeesDetailsById --
##################################################
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
