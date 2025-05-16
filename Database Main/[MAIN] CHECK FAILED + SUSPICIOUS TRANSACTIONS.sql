use main;
INSERT INTO CUSTOMERS (
     cus_first_name, cus_last_name, cus_dob, cus_email, cus_address,
    cus_phone_num, cus_sex, cus_identification_id, cus_join_date, branch_id
) VALUES (
     'John', 'Doe', '1990-01-01', 'john@example.com', '123 Main St',
    '+84 901238881', 'Male', 'ID123456789', '2017-05-14', 'HN'
);
SELECT * FROM CUSTOMER_accounts;
-- Saving Account
INSERT INTO CUSTOMER_ACCOUNTS (
	cus_id, cus_account_status, cus_account_type_id, opening_date
) VALUES (
    'DTNBHN170000001',  'Active', 'S', '2017-05-14'
);

-- Checking Accounts
INSERT INTO CUSTOMER_ACCOUNTS (
    cus_id, cus_account_status, cus_account_type_id, opening_date
) VALUES
    ( 'DTNBHN170000001', 'Active', 'C', '2017-05-14'),
    ( 'DTNBHN170000001', 'Active', 'C', '2017-05-14'),
    ( 'DTNBHN170000001', 'Temporarily Locked', 'C', '2017-05-14');

-- Fixed Deposit Account
INSERT INTO CUSTOMER_ACCOUNTS (
     cus_id, cus_account_status, cus_account_type_id, opening_date
) VALUES (
    'DTNBHN170000001', 'Active', 'F', '2017-05-14'
);

-- Update Saving Account Balance
UPDATE SAVING_ACCOUNTS
SET saving_acc_balance = 200000
WHERE cus_account_id = 'DTNBS17000001';

-- Update Checking Account Balances and Limits
UPDATE CHECK_ACCOUNTS -- Check lỗi - 01
SET 
    check_acc_balance = 2000000, -- 2tr
    transfer_limit = 1500000, -- 1tr5
    daily_transfer_limit = 1900000 -- 1tr9
WHERE cus_account_id = 'DTNBC170000001';
select * from check_accounts;
UPDATE CHECK_ACCOUNTS -- Tk check daily trasfer 02
SET 
    check_acc_balance = 20000000,
    transfer_limit = 350000,
    daily_transfer_limit = 500000
WHERE cus_account_id = 'DTNBC170000002';

UPDATE CHECK_ACCOUNTS-- TK nhận tiền
SET 
    check_acc_balance = 2000000,
    daily_transfer_limit = 100000000
WHERE cus_account_id = 'DTNBC170000003';

-- Update Fixed Deposit Account Balance
UPDATE FIXED_DEPOSIT_ACCOUNTS
SET deposit_amount = 2000000
WHERE cus_account_id = 'DTNBHN170000001';


select * from TRANSACTION_ERROR_CODES;
select * from failed_transactions;
select * from customer_accounts;
SELECT * 
FROM TRANSACTIONS
ORDER BY trans_time ASC;
############################################################
				-- CHECK TRANSACTION ERRORS --
############################################################

INSERT INTO TRANSACTIONS ( -- Check vượt daily_transfer_limit & gửi vào tk locked -- lỗi, lẽ ra phải check vượt tranfer_lim trước
    trans_type_id, cus_account_id, related_cus_account_id, trans_amount,
    direction, trans_time, last_updated,  trans_error_code
) VALUES
    ('TRF', 'DTNBC170000002', 'DTNBC170000001', 360000, 'Debit', '2017-05-14 14:12:00', '2017-05-14 14:12:00',  NULL), -- Exceeded the transaction limit
    ('TRF', 'DTNBC170000002', 'DTNBC170000001', 190000, 'Debit', '2017-05-14 14:12:00', '2017-05-14 14:12:00',  NULL), -- ok
    ('TRF', 'DTNBC170000002', 'DTNBC170000001', 290000, 'Debit', '2017-05-14 14:12:00', '2017-05-14 14:12:00',  NULL), -- ok
    ('TRF', 'DTNBC170000002', 'DTNBC170000001', 190000, 'Debit', '2017-05-14 14:12:00', '2017-05-14 14:12:00',  NULL), -- Exceeded the daily transaction limit  (190K+290K+190K < 500K)
    ('TRF', 'DTNBC170000002', 'DTNBC170000003', 1800, 'Debit', '2017-05-14 14:12:00', '2017-05-14 14:12:00',  NULL); -- The destination account has been locked
INSERT INTO TRANSACTIONS ( -- Source and destination accounts are the same
    trans_type_id, cus_account_id, related_cus_account_id, trans_amount,
    direction, trans_time, last_updated,  trans_error_code
) VALUES
    ( 'TRF', 'DTNBC170000001', 'DTNBC170000001', 40000000, 'Debit', '2017-05-14 14:14:00', '2017-05-14 14:14:00',  NULL);
INSERT INTO TRANSACTIONS ( -- Destination accounts is invalid
    trans_type_id, cus_account_id, related_cus_account_id, trans_amount,
    direction, trans_time, last_updated,  trans_error_code
) VALUES
    ( 'TRF', 'DTNBC170000001', 'DTNBS00000111', 17000000, 'Debit', '2017-05-14 14:16:00', '2017-05-14 14:16:00',  NULL);
############################################################
				-- CHECK FRAUD PATTERN --
############################################################
-- Locked Account for testing
SET SQL_SAFE_UPDATES = 0;
UPDATE CHECK_ACCOUNTS -- Tk check daily trasfer 02
SET 
    check_acc_balance = 20000000000000,
    transfer_limit = 9000000,
    daily_transfer_limit = 500000000000000
WHERE cus_account_id = 'DTNBC170000002';
-- Test case 2: 5 giao dịch trong 15 phút vượt 10x trung bình (trung bình ~1.4tr, 10x = 14tr)
-- Lower yearly average for ACC002 by inserting small transactions
-- Insert small transactions (before amount spike)
INSERT INTO TRANSACTIONS ( -- Check vượt daily_transfer_limit & gửi vào tk locked -- lỗi, lẽ ra phải check vượt tranfer_lim trước
    trans_type_id, cus_account_id, related_cus_account_id, trans_amount,
    direction, trans_time, last_updated
) VALUES
( 'TRF', 'DTNBC170000002', 'DTNBC170000001', 100000, 'Debit', DATE_SUB(NOW(), INTERVAL 350 DAY), DATE_SUB(NOW(), INTERVAL 350 DAY)),
( 'TRF', 'DTNBC170000002', 'DTNBC170000001', 120000, 'Debit', DATE_SUB(NOW(), INTERVAL 330 DAY), DATE_SUB(NOW(), INTERVAL 330 DAY)),
( 'TRF', 'DTNBC170000002', 'DTNBC170000001', 95000,  'Debit', DATE_SUB(NOW(), INTERVAL 310 DAY), DATE_SUB(NOW(), INTERVAL 310 DAY)),
( 'TRF', 'DTNBC170000002', 'DTNBC170000001', 110000, 'Debit', DATE_SUB(NOW(), INTERVAL 290 DAY), DATE_SUB(NOW(), INTERVAL 290 DAY)),
( 'TRF', 'DTNBC170000002', 'DTNBC170000001', 105000, 'Debit', DATE_SUB(NOW(), INTERVAL 270 DAY), DATE_SUB(NOW(), INTERVAL 270 DAY)),
( 'TRF', 'DTNBC170000002', 'DTNBC170000001', 98000,  'Debit', DATE_SUB(NOW(), INTERVAL 240 DAY), DATE_SUB(NOW(), INTERVAL 240 DAY)),
( 'TRF', 'DTNBC170000002', 'DTNBC170000001', 102000, 'Debit', DATE_SUB(NOW(), INTERVAL 220 DAY), DATE_SUB(NOW(), INTERVAL 220 DAY)),
( 'TRF', 'DTNBC170000002', 'DTNBC170000001', 100000, 'Debit', DATE_SUB(NOW(), INTERVAL 200 DAY), DATE_SUB(NOW(), INTERVAL 200 DAY)),
(  'TRF', 'DTNBC170000002', 'DTNBC170000001', 99000,  'Debit', DATE_SUB(NOW(), INTERVAL 180 DAY), DATE_SUB(NOW(), INTERVAL 180 DAY)),
( 'TRF', 'DTNBC170000002', 'DTNBC170000001', 97000,  'Debit', DATE_SUB(NOW(), INTERVAL 160 DAY), DATE_SUB(NOW(), INTERVAL 160 DAY)),
( 'TRF', 'DTNBC170000002', 'DTNBC170000001', 103000, 'Debit', DATE_SUB(NOW(), INTERVAL 140 DAY), DATE_SUB(NOW(), INTERVAL 140 DAY)),
('TRF', 'DTNBC170000002', 'DTNBC170000001', 101000, 'Debit', DATE_SUB(NOW(), INTERVAL 120 DAY), DATE_SUB(NOW(), INTERVAL 120 DAY)),
( 'TRF', 'DTNBC170000002', 'DTNBC170000001', 95000,  'Debit', DATE_SUB(NOW(), INTERVAL 100 DAY), DATE_SUB(NOW(), INTERVAL 100 DAY)),
(  'TRF', 'DTNBC170000002', 'DTNBC170000001', 98000,  'Debit', DATE_SUB(NOW(), INTERVAL 80 DAY), DATE_SUB(NOW(), INTERVAL 80 DAY)),
('TRF', 'DTNBC170000002', 'DTNBC170000001', 99000,  'Debit', DATE_SUB(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 60 DAY)),
( 'TRF', 'DTNBC170000002', 'DTNBC170000001', 96000,  'Debit', DATE_SUB(NOW(), INTERVAL 40 DAY), DATE_SUB(NOW(), INTERVAL 40 DAY)),
(  'TRF', 'DTNBC170000002', 'DTNBC170000001', 97000,  'Debit', DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY));


-- Insert the large spike transactions (these should come after the small ones)
INSERT INTO TRANSACTIONS  ( 
    trans_type_id, cus_account_id, related_cus_account_id, trans_amount,
    direction, trans_time, last_updated
) VALUES
('TRF', 'DTNBC170000002', 'DTNBC170000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 15 MINUTE), DATE_SUB(NOW(), INTERVAL 15 MINUTE)),
('TRF', 'DTNBC170000002', 'DTNBC170000001', 3500000, 'Debit', DATE_SUB(NOW(), INTERVAL 12 MINUTE), DATE_SUB(NOW(), INTERVAL 12 MINUTE)),
('TRF', 'DTNBC170000002', 'DTNBC170000001', 4000000, 'Debit', DATE_SUB(NOW(), INTERVAL 11 MINUTE), DATE_SUB(NOW(), INTERVAL 10 MINUTE)),
('TRF', 'DTNBC170000002', 'DTNBC170000001', 2500000, 'Debit', DATE_SUB(NOW(), INTERVAL 9 MINUTE), DATE_SUB(NOW(), INTERVAL 8 MINUTE)),
('TRF', 'DTNBC170000002', 'DTNBC170000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 8 MINUTE), DATE_SUB(NOW(), INTERVAL 5 MINUTE)),
('TRF', 'DTNBC170000002', 'DTNBC170000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 7 MINUTE), DATE_SUB(NOW(), INTERVAL 3 MINUTE)),
('TRF', 'DTNBC170000002', 'DTNBC170000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 6 MINUTE), DATE_SUB(NOW(), INTERVAL 2 MINUTE)),
('TRF', 'DTNBC170000002', 'DTNBC170000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 5 MINUTE), DATE_SUB(NOW(), INTERVAL 5 MINUTE)),
('TRF', 'DTNBC170000002', 'DTNBC170000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 4 MINUTE), DATE_SUB(NOW(), INTERVAL 3 MINUTE)),
('TRF', 'DTNBC170000002', 'DTNBC170000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 2 MINUTE), DATE_SUB(NOW(), INTERVAL 2 MINUTE));
-- Tạo khách hàng mới
select * from event_log;
select * from suspicions;
-- Gắn tài khoản với khách hàng
INSERT INTO CUSTOMER_ACCOUNTS (
    cus_account_id, cus_id, cus_account_status, cus_account_type_id
)
VALUES (
    'ACC003', 'CUS001', 'Active', 'C'
);
UPDATE CHECK_ACCOUNTS
SET check_acc_balance = 200000000
    WHERE cus_account_id = "ACC003" ;
INSERT INTO TRANSACTIONS (
    trans_id, trans_type_id, cus_account_id, related_cus_account_id, trans_amount,
    direction, trans_time, last_updated, trans_status
)
VALUES (
    'AS301', 'TRF', 'ACC003', 'ACC001', 100000, 'Debit',
    DATE_SUB(NOW(), INTERVAL 100 DAY), DATE_SUB(NOW(), INTERVAL 100 DAY), 'Successful'
);
INSERT INTO TRANSACTIONS (
    trans_id, trans_type_id, cus_account_id, related_cus_account_id, trans_amount,
    direction, trans_time, last_updated, trans_status
)
VALUES (
    'AS302', 'TRF', 'ACC003', 'ACC001', 80000000, 'Debit',
    NOW(), NOW(), 'Successful'
);
select * from debug_log_2;
select * from TEMP_suspicions;
select * from suspicions;

SELECT count(*)
FROM SUSPICIONS s
JOIN TRANSACTIONS t ON s.trans_id = t.trans_id
WHERE t.cus_account_id = 'ACC002'
	AND s.severity_level = 'High'
    AND s.suspicion_status != 'False_positive';



-- INSERT INTO CHECK_ACCOUNTS VALUES ('DTNBC25000011', 50000000 ,1, 100000, 1000000);
-- INSERT INTO TRANSACTIONS VALUES ('TXN007', 'TRF', 'DTNBC25000011', 'DTNBS25000001', 500000, 'Debit', NOW(), NOW(), 'Successful', NULL);


