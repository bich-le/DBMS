use main;
SET GLOBAL event_scheduler = ON;
SET SQL_SAFE_UPDATES = 0;

####################################################################################################################################################################
				
											-- ID AUTOMATIONAL SETTINGS --
				
                
####################################################################################################################################################################
DELIMITER $$

CREATE TRIGGER trg_generate_customer_id
BEFORE INSERT ON CUSTOMERS
FOR EACH ROW
BEGIN
    DECLARE idx INT;
    DECLARE yy CHAR(2);

    -- Use cus_join_date year if given, otherwise use current date
    SET yy = DATE_FORMAT(IFNULL(NEW.cus_join_date, CURRENT_TIMESTAMP), '%y');

    -- Increase or initialize the index for (branch_id, year)
    INSERT INTO CUSTOMERS_INDEX(branch_id, year, current_index)
    VALUES (NEW.branch_id, yy, 1)
    ON DUPLICATE KEY UPDATE current_index = current_index + 1;

    -- Get the updated index
    SELECT current_index INTO idx
    FROM CUSTOMERS_INDEX
    WHERE branch_id = NEW.branch_id AND year = yy;

    -- Set the new customer ID
    SET NEW.cus_ID = CONCAT('DTNB', NEW.branch_id, yy, LPAD(idx, 7, '0'));
END$$

DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_generate_customer_account_id
BEFORE INSERT ON CUSTOMER_ACCOUNTS
FOR EACH ROW
BEGIN
    DECLARE idx INT;
    DECLARE yy CHAR(2);

    -- Ưu tiên opening_date nếu có, không thì lấy CURRENT_DATE
    SET yy = IFNULL(DATE_FORMAT(NEW.opening_date, '%y'), DATE_FORMAT(CURRENT_DATE, '%y'));

    INSERT INTO CUSTOMER_ACCOUNT_INDEX(cus_account_type_id, year, current_index)
    VALUES (NEW.cus_account_type_id, yy, 1)
    ON DUPLICATE KEY UPDATE current_index = current_index + 1;

    -- Lấy chỉ số mới
    SELECT current_index INTO idx
    FROM CUSTOMER_ACCOUNT_INDEX
    WHERE cus_account_type_id = NEW.cus_account_type_id AND year = yy;

    -- Tạo mã tài khoản: DTNB + Loại + Năm + Số thứ tự
    SET NEW.cus_account_id = CONCAT('DTNB', NEW.cus_account_type_id, yy, LPAD(idx, 7, '0'));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_generate_emp_id
BEFORE INSERT ON EMPLOYEES
FOR EACH ROW
BEGIN
    DECLARE idx INT;
    DECLARE yy CHAR(2);
	SET yy = IFNULL(DATE_FORMAT(NEW.emp_join_date, '%y'), DATE_FORMAT(CURRENT_DATE, '%y'));
    
    INSERT INTO EMPLOYEE_ACCOUNT_INDEX ( branch_id, emp_position_id, year, current_index)
    VALUES (NEW.branch_id, NEW.emp_position_id, yy, 1)
    ON DUPLICATE KEY UPDATE current_index = current_index + 1;

    -- Lấy chỉ số mới sau khi cập nhật
    SELECT current_index INTO idx
    FROM EMPLOYEE_ACCOUNT_INDEX
    WHERE branch_id = NEW.branch_id AND emp_position_id = NEW.emp_position_id AND year = yy;

    SET NEW.emp_id = CONCAT(NEW.branch_id, NEW.emp_position_id,  yy, LPAD(idx, 4, '0'));
END$$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER trg_generate_trans_id
BEFORE INSERT ON TRANSACTIONS
FOR EACH ROW
BEGIN
    DECLARE idx INT;
    DECLARE yy CHAR(2);
    DECLARE dd CHAR(2);

    -- Lấy năm (2 chữ số) và ngày (2 chữ số)
    SET yy = IFNULL(DATE_FORMAT(NEW.trans_time, '%y'), DATE_FORMAT(CURRENT_DATE, '%y'));
    SET dd = IFNULL(DATE_FORMAT(NEW.trans_time, '%d'), DATE_FORMAT(CURRENT_DATE, '%d'));

    -- Tăng chỉ số cho trans_type_id + year hoặc thêm mới
    INSERT INTO TRANSACTION_INDEX (trans_type_id, year_suffix, current_index)
    VALUES (NEW.trans_type_id, yy, 1)
    ON DUPLICATE KEY UPDATE current_index = current_index + 1;

    -- Lấy chỉ số mới sau khi cập nhật
    SELECT current_index INTO idx
    FROM TRANSACTION_INDEX
    WHERE trans_type_id = NEW.trans_type_id AND year_suffix = yy;

    -- Tạo trans_id: 'DTNB' + trans_type_id + yy + padded index + dd
    SET NEW.trans_id = CONCAT('DTNB', NEW.trans_type_id, yy, LPAD(idx, 7, '0'), dd);
END$$

DELIMITER ;

####################################################################################################################################################################
				
											-- CUSTOMER ACCOUNTS --
				
                
####################################################################################################################################################################

##################################################################################
		-- AUTOMATICALLY INSERT INTO SUPTYPE ACCOUNT TABLES --
##################################################################################
DELIMITER $$
CREATE TRIGGER after_insert_customer_account
AFTER INSERT ON CUSTOMER_ACCOUNTS
FOR EACH ROW
BEGIN
    DECLARE matched_interest_id TINYINT;

    -- Trường hợp: CHECK ACCOUNT
    IF NEW.cus_account_type_id = 'C' THEN
        SELECT interest_rate_id INTO matched_interest_id
        FROM INTEREST_RATES
        WHERE cus_account_type_id = 'C'
          AND status = 'Active'
        ORDER BY interest_rate_val DESC
        LIMIT 1;

        -- INSERT INTO CHECK_ACCOUNTS (cus_account_id, check_acc_balance, interest_rate_id, transfer_limit, daily_transfer_limit)
        INSERT INTO CHECK_ACCOUNTS (cus_account_id, check_acc_balance, interest_rate_id)
        VALUES (NEW.cus_account_id, 0, matched_interest_id);

    -- Trường hợp: SAVING ACCOUNT
    ELSEIF NEW.cus_account_type_id = 'S' THEN
        SELECT interest_rate_id INTO matched_interest_id
        FROM INTEREST_RATES
        WHERE cus_account_type_id = 'S'
          AND status = 'Active'
        ORDER BY interest_rate_val DESC
        LIMIT 1;

        INSERT INTO SAVING_ACCOUNTS (cus_account_id, saving_acc_balance, interest_rate_id)
        VALUES (NEW.cus_account_id, 0, matched_interest_id);

    -- Trường hợp: FIXED DEPOSIT ACCOUNT
    ELSEIF NEW.cus_account_type_id = 'F' THEN
        SELECT interest_rate_id INTO matched_interest_id
        FROM INTEREST_RATES
        WHERE cus_account_type_id = 'F'
          AND status = 'Active'
          AND term = 6
        ORDER BY interest_rate_val DESC
        LIMIT 1;

        INSERT INTO FIXED_DEPOSIT_ACCOUNTS (cus_account_id, interest_rate_id, deposit_date, maturity_date)
        VALUES (
            NEW.cus_account_id,
            matched_interest_id,
            NEW.opening_date,
            DATE_ADD(NEW.opening_date, INTERVAL 6 MONTH)
        );
    END IF;
END $$

DELIMITER ;
####################################################################################################################################################################
				
											-- TRANSACTIONS --
				
                
####################################################################################################################################################################
##################################################################################
	-- CHECK IF TRANSACTION_TYPE IS AVAILABLE FOR THE CUSTOMER ACCOUNT TYPE --
##################################################################################
DELIMITER //

CREATE TRIGGER validate_transaction_type
BEFORE INSERT ON TRANSACTIONS
FOR EACH ROW
BEGIN
    DECLARE account_type VARCHAR(2);
    DECLARE is_allowed BOOLEAN DEFAULT FALSE;
    DECLARE maturity_date_val DATE;
    
    -- Lấy loại tài khoản
    SELECT cus_account_type_id INTO account_type
    FROM CUSTOMER_ACCOUNTS
    WHERE cus_account_id = NEW.cus_account_id;
    
    -- Kiểm tra loại giao dịch
    CASE account_type
        WHEN 'C' THEN -- Tài khoản thanh toán
            SET is_allowed = NEW.trans_type_id IN ('POS','DEP','WDL','TRF','PMT','ACH','INT','FEE','CHK','REF');
            
        WHEN 'S' THEN -- Tài khoản tiết kiệm
            SET is_allowed = NEW.trans_type_id IN ('DEP','WDL','TRF','ACH','INT','FEE','REF');
            
        WHEN 'F' THEN -- Tài khoản kỳ hạn
            IF NEW.trans_type_id = 'WDL' THEN
                SELECT maturity_date INTO maturity_date_val
                FROM FIXED_DEPOSIT_ACCOUNTS 
                WHERE cus_account_id = NEW.cus_account_id;
                
                IF maturity_date_val IS NOT NULL THEN
                    IF maturity_date_val > NEW.trans_time THEN 
                        -- Rút trước hạn
                        SET NEW.trans_error_code = 'EWP';
                        SET NEW.trans_amount = NEW.trans_amount * 0.95; -- Phạt 5%
                        SET is_allowed = TRUE;
                    ELSE 
                        -- Rút đúng hoặc sau hạn
                        SET is_allowed = TRUE;
                    END IF;
                END IF;
            ELSE
                SET is_allowed = NEW.trans_type_id IN ('DEP','INT','FEE');
            END IF;
    END CASE;

    IF NOT is_allowed THEN
        SET NEW.trans_status = 'Failed';
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid transaction type for this account';
    END IF;
END//

DELIMITER ;
##################################################################################
				-- CHECK IF TRANSACTIONS ARE VALLID --
##################################################################################
DELIMITER //

CREATE TRIGGER validate_transaction_before_insert
BEFORE INSERT ON TRANSACTIONS
FOR EACH ROW
BEGIN
    DECLARE v_account_status VARCHAR(20);
    DECLARE v_balance BIGINT;
    DECLARE v_dest_account_status VARCHAR(20);
    DECLARE v_daily_total DECIMAL(18,2);
    DECLARE v_daily_limit DECIMAL(18,2);
    DECLARE v_transaction_limit int;
    
 

    
    -- Check balance for Debit transactions
    IF NEW.direction = 'Debit' THEN
        SELECT 
            CASE 
                WHEN ca.cus_account_type_id = 'S' THEN sa.saving_acc_balance
                WHEN ca.cus_account_type_id = 'C' THEN ca2.check_acc_balance
                WHEN ca.cus_account_type_id = 'F' THEN fa.deposit_amount
            END INTO v_balance
        FROM CUSTOMER_ACCOUNTS ca
        LEFT JOIN SAVING_ACCOUNTS sa ON ca.cus_account_id = sa.cus_account_id
        LEFT JOIN CHECK_ACCOUNTS ca2 ON ca.cus_account_id = ca2.cus_account_id
        LEFT JOIN FIXED_DEPOSIT_ACCOUNTS fa ON ca.cus_account_id = fa.cus_account_id
        WHERE ca.cus_account_id = NEW.cus_account_id;
        
        IF v_balance < NEW.trans_amount THEN
            SET NEW.trans_status = 'Failed';
            SET NEW.trans_error_code = 'BAL-001';
            -- SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'Insufficient balance'; 
        END IF;
    END IF;
     IF NEW.trans_type_id = 'TRF' AND NEW.direction = 'Debit' THEN
        -- Tổng số tiền đã chuyển trong ngày (chỉ tính giao dịch thành công)
        SELECT COALESCE(SUM(trans_amount), 0) INTO v_daily_total
        FROM TRANSACTIONS
        WHERE cus_account_id = NEW.cus_account_id
        AND DATE(trans_time) = DATE(NEW.trans_time)
        AND direction = 'Debit'
        AND trans_status = 'Successful';

        -- Lấy giới hạn ngày
        SELECT daily_transfer_limit INTO v_daily_limit
        FROM CHECK_ACCOUNTS
        WHERE cus_account_id = NEW.cus_account_id;

        IF (v_daily_total + NEW.trans_amount) > v_daily_limit THEN
            SET NEW.trans_status = 'Failed';
            SET NEW.trans_error_code = 'LIMIT-002';
        END IF;
                END IF;
		IF NEW.direction = 'Debit' THEN
         -- Lấy giới hạn từng giao dịch
        SELECT transfer_limit INTO v_transaction_limit
        FROM CHECK_ACCOUNTS
        WHERE cus_account_id = NEW.cus_account_id;

        IF NEW.trans_amount > v_transaction_limit THEN
            SET NEW.trans_status = 'Failed';
            SET NEW.trans_error_code = 'LIMIT-001';
        END IF;
        END IF;

    -- Kiểm tra hạn mức giao dịch trong ngày nếu là chuyển tiền Debit
   -- Check for same source and destination accounts
    IF NEW.trans_type_id = 'TRF' AND NEW.related_cus_account_id = NEW.cus_account_id THEN
        SET NEW.trans_status = 'Failed';
        SET NEW.trans_error_code = 'VAL-001';
        -- SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Cannot transfer to the same account';
    END IF;
         -- Check if destination account exists (for transfer transactions)
    IF NEW.trans_type_id = 'TRF' THEN
        IF NOT EXISTS (
            SELECT 1
            FROM CUSTOMER_ACCOUNTS
            WHERE cus_account_id = NEW.related_cus_account_id
        ) THEN
            SET NEW.trans_status = 'Failed';
            SET NEW.trans_error_code = 'VAL-002';
    END IF;
    END IF;
    -- Check account status
    IF NEW.trans_type_id = 'TRF' THEN
        SELECT cus_account_status INTO v_dest_account_status 
        FROM CUSTOMER_ACCOUNTS 
        WHERE cus_account_id = NEW.related_cus_account_id;
        
        IF v_dest_account_status != 'Active' THEN
            SET NEW.trans_status = 'Failed';
            SET NEW.trans_error_code = 'ACC-001';
        END IF;
    END IF;
END;
//
DELIMITER ;

##################################################################################
	 -- AUTOMATICALLY INSERT INVALID TRANSACTIONS INTO FAILED_TRANSACTIONS --
##################################################################################
DELIMITER //
CREATE TRIGGER after_transaction_failed
AFTER INSERT ON TRANSACTIONS
FOR EACH ROW
BEGIN
    IF NEW.trans_status = 'Failed' 
    THEN
        INSERT INTO FAILED_TRANSACTIONS (
            trans_id,
            cus_account_id,
            trans_error_code,
            trans_amount,
            failure_reason,
            attempted_time
        ) VALUES (
            NEW.trans_id,
            NEW.cus_account_id,
            NEW.trans_error_code,
            NEW.trans_amount,
            COALESCE((SELECT description FROM TRANSACTION_ERROR_CODES WHERE trans_error_code = NEW.trans_error_code), 'Unknown error'),
            NEW.trans_time
        );
    END IF;
END//
DELIMITER ;
select * from transactions;


##################################################################################
				-- Ensure double-entry bookkeeping principle --
##################################################################################
-- 
DELIMITER //

CREATE TRIGGER tr_auto_create_credit_after_debit
AFTER INSERT ON TRANSACTIONS
FOR EACH ROW
BEGIN
    -- Chỉ xử lý khi là giao dịch Debit thành công và có tài khoản liên quan
    IF NEW.direction = 'Debit' AND NEW.trans_status = 'Successful' AND NEW.related_cus_account_id IS NOT NULL THEN
        -- Thêm vào bảng PENDING_CREDITS để xử lý sau
        INSERT INTO PENDING_CREDITS (
            trans_type_id,
            cus_account_id,
            related_cus_account_id,
            trans_amount,
            trans_time,
            last_updated
        ) VALUES (
            NEW.trans_type_id,
            NEW.related_cus_account_id, -- Tài khoản nhận sẽ là tài khoản ghi Có
            NEW.cus_account_id,          -- Tài khoản ghi Nợ sẽ là tài khoản liên quan
            NEW.trans_amount,
            NEW.trans_time,
            NOW()
        );
        
        -- Ghi log
        INSERT INTO EVENT_LOG (message) 
        VALUES (CONCAT('Auto-created pending credit for debit transaction: ', NEW.trans_id));
    END IF;
END //

DELIMITER ;
-- 
DELIMITER //

CREATE PROCEDURE process_pending_credits()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id INT;
    DECLARE v_trans_type_id VARCHAR(3);
    DECLARE v_cus_account_id VARCHAR(17);
    DECLARE v_related_cus_account_id VARCHAR(17);
    DECLARE v_trans_amount INT;
    DECLARE v_trans_time DATETIME;
    
    -- Khai báo cursor để lấy các bản ghi chưa xử lý
    DECLARE cur CURSOR FOR 
        SELECT id, trans_type_id, cus_account_id, related_cus_account_id, trans_amount, trans_time
        FROM PENDING_CREDITS
        ORDER BY created_at;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_id, v_trans_type_id, v_cus_account_id, v_related_cus_account_id, v_trans_amount, v_trans_time;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Gọi procedure tạo giao dịch Credit
        CALL create_credit_transaction(
            v_trans_type_id,
            v_cus_account_id,
            v_related_cus_account_id,
            v_trans_amount,
            v_trans_time
        );
        
        -- Xóa bản ghi đã xử lý
        DELETE FROM PENDING_CREDITS WHERE id = v_id;
    END LOOP;
    
    CLOSE cur;
END //

DELIMITER ;
DELIMITER //

CREATE PROCEDURE create_credit_transaction(
    IN p_trans_type_id VARCHAR(3),
    IN p_cus_account_id VARCHAR(17),
    IN p_related_cus_account_id VARCHAR(17),
    IN p_trans_amount INT,
    IN p_trans_time DATETIME
)
BEGIN
    -- Thêm giao dịch Credit mà không cần xử lý trans_id
    INSERT INTO TRANSACTIONS (
        trans_type_id,
        cus_account_id,
        related_cus_account_id,
        trans_amount,
        direction,
        trans_time,
        trans_status
    ) VALUES (
        p_trans_type_id,
        p_cus_account_id,
        p_related_cus_account_id,
        p_trans_amount,
        'Credit',
        p_trans_time,
        'Successful'
    );
    

    INSERT INTO EVENT_LOG (message) 
    VALUES (CONCAT('Created credit transaction for debit to account: ', p_related_cus_account_id, 
                  '. Amount: ', p_trans_amount, 
                  '. New transaction ID generated by system.'));
END //

DELIMITER ;
DELIMITER //

CREATE EVENT IF NOT EXISTS event_process_pending_credits
ON SCHEDULE EVERY 5 SECOND
DO
BEGIN
    CALL process_pending_credits();
END //

DELIMITER ;

##################################################################################
						-- Update balance after transactions --
##################################################################################

DELIMITER //

CREATE TRIGGER update_account_balance
AFTER INSERT ON TRANSACTIONS
FOR EACH ROW
BEGIN
    DECLARE account_type VARCHAR(2);
    
    -- Chỉ xử lý giao dịch thành công
    IF NEW.trans_status = 'Successful' THEN
        -- Xác định loại tài khoản
        SELECT cus_account_type_id INTO account_type
        FROM CUSTOMER_ACCOUNTS
        WHERE cus_account_id = NEW.cus_account_id;
        
        -- Xử lý cho tài khoản chính (cus_account_id)
        CASE 
            WHEN NEW.direction = 'Debit' THEN
                -- Trừ tiền từ tài khoản nguồn (Debit)
                CASE account_type
                    WHEN 'C' THEN -- Checking account
                        UPDATE CHECK_ACCOUNTS
                        SET check_acc_balance = check_acc_balance - NEW.trans_amount
                        WHERE cus_account_id = NEW.cus_account_id;
                        
                    WHEN 'S' THEN -- Saving account
                        UPDATE SAVING_ACCOUNTS
                        SET saving_acc_balance = saving_acc_balance - NEW.trans_amount
                        WHERE cus_account_id = NEW.cus_account_id;
                        
                    WHEN 'F' THEN -- Fixed deposit
                        -- Xử lý rút tiền từ tài khoản tiết kiệm có kỳ hạn
                        UPDATE FIXED_DEPOSIT_ACCOUNTS
                        SET deposit_amount = deposit_amount - NEW.trans_amount
                        WHERE cus_account_id = NEW.cus_account_id;
                END CASE;
                
            WHEN NEW.direction = 'Credit' THEN
                -- Cộng tiền vào tài khoản đích (Credit)
                CASE account_type
                    WHEN 'C' THEN -- Checking account
                        UPDATE CHECK_ACCOUNTS
                        SET check_acc_balance = check_acc_balance + NEW.trans_amount
                        WHERE cus_account_id = NEW.cus_account_id;
                        
                    WHEN 'S' THEN -- Saving account
                        UPDATE SAVING_ACCOUNTS
                        SET saving_acc_balance = saving_acc_balance + NEW.trans_amount
                        WHERE cus_account_id = NEW.cus_account_id;
                        
                    WHEN 'F' THEN -- Fixed deposit
                        -- Xử lý gửi tiền vào tài khoản tiết kiệm có kỳ hạn
                        UPDATE FIXED_DEPOSIT_ACCOUNTS
                        SET deposit_amount = deposit_amount + NEW.trans_amount
                        WHERE cus_account_id = NEW.cus_account_id;
                END CASE;
        END CASE;       
    END IF;
END //

DELIMITER ;
####################################################################################################################################################################
				
											-- FRAUD DETECTION --
				
                
####################################################################################################################################################################

##################################################################################
						-- Detect Fraud 1: Amount Spike --
##################################################################################

DELIMITER //
CREATE TRIGGER detect_amount_spike
AFTER INSERT ON TRANSACTIONS
FOR EACH ROW
BEGIN
    DECLARE yearly_avg DECIMAL(20,2) DEFAULT 0;
    DECLARE pattern_id INT DEFAULT NULL;
    DECLARE recent_trans_count INT DEFAULT 0;
    DECLARE recent_trans_total DECIMAL(20,2) DEFAULT 0;

    -- Chỉ kiểm tra giao dịch Debit
    IF NEW.trans_status = 'Successful' AND NEW.direction = 'Debit' THEN

        -- Lấy pattern ID
        SELECT fraud_pattern_id INTO pattern_id
        FROM FRAUD_PATTERNS
        WHERE fraud_pattern_name = 'Transaction Amount Spike'
        LIMIT 1;

        IF pattern_id IS NOT NULL THEN
            -- Tính trung bình 1 năm chỉ cho giao dịch Debit
            SELECT IFNULL(AVG(trans_amount), 0) INTO yearly_avg
            FROM TRANSACTIONS
            WHERE cus_account_id = NEW.cus_account_id
              AND trans_status = 'Successful'
              AND direction = 'Debit'
              AND trans_time >= DATE_SUB(NEW.trans_time, INTERVAL 1 YEAR);

            -- Đếm giao dịch Debit trong 15 phút
            SELECT COUNT(*), IFNULL(SUM(trans_amount), 0)
            INTO recent_trans_count, recent_trans_total
            FROM TRANSACTIONS
            WHERE cus_account_id = NEW.cus_account_id
              AND trans_status = 'Successful'
              AND direction = 'Debit'
              AND trans_time BETWEEN DATE_SUB(NEW.trans_time, INTERVAL 15 MINUTE) AND NEW.trans_time;

            -- Kiểm tra điều kiện bất thường
            IF yearly_avg > 0 AND recent_trans_count >= 5 AND recent_trans_total > (yearly_avg * 10) THEN
                INSERT INTO TEMP_SUSPICIONS (trans_id, fraud_pattern_id, detected_time, severity_level)
                VALUES (NEW.trans_id, pattern_id, NOW(), 'Low');
            END IF;
        END IF;
    END IF;
END//
DELIMITER ;


##################################################################################
				  -- Detect Fraud 2: Dormant Account Activity --
##################################################################################

DELIMITER ;
-- Dormant acc activity trigger
DELIMITER //

CREATE TRIGGER detect_dormant_activity
AFTER INSERT ON TRANSACTIONS
FOR EACH ROW
BEGIN
    DECLARE last_trans_date DATETIME;
    DECLARE pattern_id INT;
    
    -- Chỉ kiểm tra giao dịch thành công >= 50,000,000
    IF NEW.trans_status = 'Successful' AND NEW.trans_amount >= 50000000 THEN
        -- Lấy ID mẫu gian lận
        SELECT fraud_pattern_id INTO pattern_id 
        FROM FRAUD_PATTERNS 
        WHERE fraud_pattern_name = 'Dormant Account Activity';
        
        -- Lấy ngày giao dịch cuối cùng
        SELECT MAX(trans_time) INTO last_trans_date
        FROM TRANSACTIONS
        WHERE cus_account_id = NEW.cus_account_id
        AND trans_id != NEW.trans_id
        AND trans_status = 'Successful';
        
        -- Kiểm tra tài khoản không hoạt động >3 tháng
        IF last_trans_date IS NOT NULL AND DATEDIFF(NEW.trans_time, last_trans_date) > 90 THEN
            -- Thêm vào bảng SUSPICIONS với severity_level tạm thời
            INSERT INTO TEMP_SUSPICIONS (trans_id, fraud_pattern_id, detected_time, severity_level)
            VALUES (NEW.trans_id, pattern_id, NOW(), 'Low');
            
            -- Log thông tin vào DEBUG_LOG
            INSERT INTO DEBUG_LOG (msg) 
            VALUES (CONCAT('Suspicion detected for ', NEW.trans_id, ': Dormant Account Activity, Account: ', NEW.cus_account_id, ', Transaction Date: ', NEW.trans_time));
        END IF;
    END IF;
END//
DELIMITER ;

##################################################################################
			-- EVENT: COPY DATA FROM TEMP_SUSPICIONS TO SUSPICIONS --
##################################################################################
DELIMITER //
CREATE EVENT move_temp_to_suspicions
ON SCHEDULE EVERY 5 SECOND
DO
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO EVENT_LOG (message) VALUES (CONCAT('Error in move_temp_to_suspicions at ', NOW()));
    END;
    
    START TRANSACTION;
    
    INSERT INTO SUSPICIONS (trans_id, fraud_pattern_id, detected_time, severity_level)
    SELECT trans_id, fraud_pattern_id, detected_time, severity_level
    FROM TEMP_SUSPICIONS
    WHERE processed = FALSE; -- Optional limit for large datasets
    
    UPDATE TEMP_SUSPICIONS
    SET processed = TRUE
    WHERE processed = FALSE
    AND trans_id IN (SELECT trans_id FROM SUSPICIONS WHERE detected_time >= DATE_SUB(NOW(), INTERVAL 1 MINUTE));
    
    INSERT INTO EVENT_LOG (message) VALUES (CONCAT('Event ran at ', NOW()));
    
    COMMIT;
END//
DELIMITER ;


##################################################################################
					-- Update severity level of suspicions --
##################################################################################
DELIMITER //

CREATE TRIGGER update_severity_based_on_violations
AFTER INSERT ON SUSPICIONS
FOR EACH ROW
BEGIN
    DECLARE violation_count INT;
    DECLARE account_id VARCHAR(17);
    DECLARE new_severity ENUM('Low', 'Medium', 'High');

    -- Lấy account ID liên quan
    SELECT cus_account_id INTO account_id
    FROM TRANSACTIONS
    WHERE trans_id = NEW.trans_id;

    -- Đếm số lần vi phạm (không tính False_positive)
    SELECT COUNT(*) INTO violation_count
    FROM SUSPICIONS s
    JOIN TRANSACTIONS t ON s.trans_id = t.trans_id
    WHERE t.cus_account_id = account_id
    AND s.suspicion_status != 'False_positive'
    AND s.suspicion_status != 'Resolved'
    AND s.fraud_pattern_id = NEW.fraud_pattern_id;

    -- Xác định mức độ nghiêm trọng
    SET new_severity = CASE
        WHEN violation_count >= 3 THEN 'High'
        WHEN violation_count = 2 THEN 'Medium'
        ELSE 'Low'
    END;

    -- Gửi dữ liệu cập nhật sang bảng trung gian
    INSERT INTO SUSPICIONS_PENDING_UPDATE (trans_id, fraud_pattern_id, detected_time, severity_level)
    VALUES (NEW.trans_id, NEW.fraud_pattern_id, NEW.detected_time, new_severity)
    ON DUPLICATE KEY UPDATE severity_level = VALUES(severity_level);

END//
DELIMITER ;
DELIMITER //
CREATE EVENT apply_pending_severity_updates
ON SCHEDULE EVERY 5 SECOND
DO
BEGIN
    START TRANSACTION;

    -- Áp dụng cập nhật mức độ nghiêm trọng
    UPDATE SUSPICIONS s
    JOIN SUSPICIONS_PENDING_UPDATE spu
    ON s.trans_id = spu.trans_id
       AND s.fraud_pattern_id = spu.fraud_pattern_id
       AND s.detected_time = spu.detected_time
    SET s.severity_level = spu.severity_level;

    -- Dọn bảng trung gian
    DELETE FROM SUSPICIONS_PENDING_UPDATE;

    COMMIT;
END//
DELIMITER ;
