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

-- Gọi thủ tục
CALL AddTransaction(
    'TRF',                          -- p_trans_type_id
    'DTNBS250000001',              -- p_cus_account_id
    'DTNBC240000001',              -- p_related_cus_account_id
    1501,                          -- p_trans_amount
    'Debit',                       -- p_direction
    'Successful',                  -- p_trans_status
    NULL,                          -- p_trans_error_code
    '2025-05-17 16:00:00',         -- p_trans_time
    '2025-05-17 16:00:00',         -- p_last_updated
    @result,                       -- OUT p_result
    @error_code                    -- OUT p_error_code
);
select * from transactions;
-- Xem kết quả
SELECT @result, @error_code;
