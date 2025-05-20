use main;
########################################################################################################################
				
                
										-- CHECK ACCOUNT SYSTEM --
                
                
########################################################################################################################
#######################################################################
					--  Auto-generated ID --
#######################################################################

INSERT INTO CUSTOMERS (-- cus_id = DTNBHN170000001
     cus_first_name, cus_last_name, cus_dob, cus_email, cus_address,
    cus_phone_num, cus_sex, cus_identification_id, cus_join_date, branch_id
) VALUES (
     'John', 'Error Transactions', '1990-01-01', 'john@example.com', '123 Main St',
    '+84 901238881', 'Male', 'ID123456789', '2017-05-14', 'HN'
);
SELECT * FROM CUSTOMERS;
#######################################################################
		--  AUTOMATICALLY INSERT INTO SUPTYPE ACCOUNT TABLES --
#######################################################################
-- Saving Account
INSERT INTO CUSTOMER_ACCOUNTS (
	cus_id, cus_account_status, cus_account_type_id, opening_date
) VALUES (
    'DTNBHN170000001',  'Active', 'S', '2017-05-14'
);
INSERT INTO CUSTOMER_ACCOUNTS (
	cus_id, cus_account_status, cus_account_type_id, opening_date
) VALUES (
    'DTNBHN170000001',  'Active', 'S', '2017-05-15'
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
select * from customer_accounts where cus_id = "DTNBHN170000001";
SELECT * FROM SAVING_ACCOUNTS ;

-- Update Saving Account Balance
UPDATE SAVING_ACCOUNTS
SET saving_acc_balance = 200000
WHERE cus_account_id = 'DTNBS17000001';

-- Update Checking Account Balances and Limits
UPDATE CHECK_ACCOUNTS --  - 01
SET 
    check_acc_balance = 2000000, -- 2tr
    transfer_limit = 1500000, -- 1tr5
    daily_transfer_limit = 1900000 -- 1tr9
WHERE cus_account_id = 'DTNBC170000001';
select * from check_accounts;
UPDATE CHECK_ACCOUNTS --  02
SET 
    check_acc_balance = 20000000, -- 20tr
    transfer_limit = 350000, -- 350k
    daily_transfer_limit = 500000 -- 500k
WHERE cus_account_id = 'DTNBC170000002';

UPDATE CHECK_ACCOUNTS-- 03
SET 
    check_acc_balance = 2000000, -- 2tr
    daily_transfer_limit = 100000000 -- 100tr
WHERE cus_account_id = 'DTNBC170000003';

-- Update Fixed Deposit Account Balance
UPDATE FIXED_DEPOSIT_ACCOUNTS
SET deposit_amount = 2000000 -- 2tr
WHERE cus_account_id = 'DTNBF170000001';
select * from fixed_deposit_accounts;
select * from failed_transactions;


########################################################################################################################
				
                
										-- CHECK TRANSACTIONS ERROR --
                
                
########################################################################################################################
select * from check_accounts where cus_account_id = 'DTNBC170000002';
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
select * from failed_transactions;
select * from transactions;
########################################################################################################################
				
                
										-- CHECK FRAUD PATTERN --
                
                
########################################################################################################################
INSERT INTO CUSTOMERS ( -- cus_id = DTNBHN070000001
     cus_first_name, cus_last_name, cus_dob, cus_email, cus_address,
    cus_phone_num, cus_sex, cus_identification_id, cus_join_date, branch_id
) VALUES (
     'John', 'Fraud', '1990-01-01', 'johnfraud@example.com', '123 Main St',
    '+84 901238884', 'Male', 'ID123456788', '2007-05-14', 'HN'
);
-- Account for test case 1
INSERT INTO CUSTOMER_ACCOUNTS ( -- cus_account_id = DTNBC080000001
	cus_id, cus_account_status, cus_account_type_id, opening_date
) VALUES (
    'DTNBHN070000001',  'Active', 'C', '2008-05-14'
);
SELECT * FROM CUSTOMER_ACCOUNTS WHERE cus_id = "DTNBHN070000001";
UPDATE CHECK_ACCOUNTS 
SET 
    check_acc_balance = 20000000000000,
    transfer_limit = 9000000,
    daily_transfer_limit = 500000000000000
WHERE cus_account_id = 'DTNBC080000001';
select * from check_accounts  WHERE cus_account_id = 'DTNBC080000001';
#######################################################################
					--  TEST CASE 1: AMOUNT SPIKE --
#######################################################################
-- 5 transactions in 15 minutes exceeding 10x average (~1.4M average, 10x = 14M)
-- Lower yearly average for ACC002 by inserting small transactions
-- Insert small transactions (before amount spike)

INSERT INTO TRANSACTIONS (
    trans_type_id, cus_account_id, related_cus_account_id, trans_amount,
    direction, trans_time, last_updated
) VALUES
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 100000, 'Debit', DATE_SUB(NOW(), INTERVAL 350 DAY), DATE_SUB(NOW(), INTERVAL 350 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 120000, 'Debit', DATE_SUB(NOW(), INTERVAL 330 DAY), DATE_SUB(NOW(), INTERVAL 330 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 95000,  'Debit', DATE_SUB(NOW(), INTERVAL 310 DAY), DATE_SUB(NOW(), INTERVAL 310 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 110000, 'Debit', DATE_SUB(NOW(), INTERVAL 290 DAY), DATE_SUB(NOW(), INTERVAL 290 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 105000, 'Debit', DATE_SUB(NOW(), INTERVAL 270 DAY), DATE_SUB(NOW(), INTERVAL 270 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 98000,  'Debit', DATE_SUB(NOW(), INTERVAL 240 DAY), DATE_SUB(NOW(), INTERVAL 240 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 102000, 'Debit', DATE_SUB(NOW(), INTERVAL 220 DAY), DATE_SUB(NOW(), INTERVAL 220 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 100000, 'Debit', DATE_SUB(NOW(), INTERVAL 200 DAY), DATE_SUB(NOW(), INTERVAL 200 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 99000,  'Debit', DATE_SUB(NOW(), INTERVAL 180 DAY), DATE_SUB(NOW(), INTERVAL 180 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 97000,  'Debit', DATE_SUB(NOW(), INTERVAL 160 DAY), DATE_SUB(NOW(), INTERVAL 160 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 103000, 'Debit', DATE_SUB(NOW(), INTERVAL 140 DAY), DATE_SUB(NOW(), INTERVAL 140 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 101000, 'Debit', DATE_SUB(NOW(), INTERVAL 120 DAY), DATE_SUB(NOW(), INTERVAL 120 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 95000,  'Debit', DATE_SUB(NOW(), INTERVAL 100 DAY), DATE_SUB(NOW(), INTERVAL 100 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 98000,  'Debit', DATE_SUB(NOW(), INTERVAL 80 DAY),  DATE_SUB(NOW(), INTERVAL 80 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 99000,  'Debit', DATE_SUB(NOW(), INTERVAL 60 DAY),  DATE_SUB(NOW(), INTERVAL 60 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 96000,  'Debit', DATE_SUB(NOW(), INTERVAL 40 DAY),  DATE_SUB(NOW(), INTERVAL 40 DAY)),
( 'TRF', 'DTNBC080000001', 'DTNBC170000001', 97000,  'Debit', DATE_SUB(NOW(), INTERVAL 20 DAY),  DATE_SUB(NOW(), INTERVAL 20 DAY));



-- Insert the large spike transactions (these should come after the small ones)
INSERT INTO TRANSACTIONS ( 
    trans_type_id, cus_account_id, related_cus_account_id, trans_amount,
    direction, trans_time, last_updated
) VALUES
('TRF', 'DTNBC080000001', 'DTNBC170000001', 3000001, 'Debit', DATE_SUB(NOW(), INTERVAL 15 MINUTE), DATE_SUB(NOW(), INTERVAL 15 MINUTE)),
('TRF', 'DTNBC080000001', 'DTNBC170000001', 3500002, 'Debit', DATE_SUB(NOW(), INTERVAL 12 MINUTE), DATE_SUB(NOW(), INTERVAL 12 MINUTE)),
('TRF', 'DTNBC080000001', 'DTNBC170000001', 4000003, 'Debit', DATE_SUB(NOW(), INTERVAL 11 MINUTE), DATE_SUB(NOW(), INTERVAL 10 MINUTE)),
('TRF', 'DTNBC080000001', 'DTNBC170000001', 2500004, 'Debit', DATE_SUB(NOW(), INTERVAL 9 MINUTE), DATE_SUB(NOW(), INTERVAL 8 MINUTE)),
('TRF', 'DTNBC080000001', 'DTNBC170000001', 3000005, 'Debit', DATE_SUB(NOW(), INTERVAL 8 MINUTE), DATE_SUB(NOW(), INTERVAL 5 MINUTE)),
('TRF', 'DTNBC080000001', 'DTNBC170000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 7 MINUTE), DATE_SUB(NOW(), INTERVAL 3 MINUTE)),
('TRF', 'DTNBC080000001', 'DTNBC170000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 6 MINUTE), DATE_SUB(NOW(), INTERVAL 2 MINUTE)),
('TRF', 'DTNBC080000001', 'DTNBC170000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 5 MINUTE), DATE_SUB(NOW(), INTERVAL 5 MINUTE)),
('TRF', 'DTNBC080000001', 'DTNBC170000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 4 MINUTE), DATE_SUB(NOW(), INTERVAL 3 MINUTE)),
('TRF', 'DTNBC080000001', 'DTNBC170000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 2 MINUTE), DATE_SUB(NOW(), INTERVAL 2 MINUTE));

-- Tạo khách hàng mới
select * from event_log;
SELECT * FROM FAILED_transactions;
select * from temp_suspicions;
select * from suspicions;
select * from transactions where trans_id = "DTNBTRF25000002919";
#######################################################################
			--  TEST CASE 1: DORMANT ACCOUNT ACTIVITY --
#######################################################################
-- First, create a dormant account (no transactions for >3 months)
INSERT INTO CUSTOMER_ACCOUNTS ( 
	cus_id, cus_account_status, cus_account_type_id, opening_date
) VALUES (
    'DTNBHN070000001',  'Active', 'C', '2008-05-14'
);
select * from transactions where cus_account_id = "DTNBC080000002";

UPDATE CHECK_ACCOUNTS 
SET 
    check_acc_balance = 20000000000000,
    transfer_limit = 90000000,
    daily_transfer_limit = 500000000000000
WHERE cus_account_id = 'DTNBC080000002';
SELECT * FROM CUSTOMER_ACCOUNTS WHERE cus_id = "DTNBHN070000001";
INSERT INTO TRANSACTIONS  ( 
    trans_type_id, cus_account_id, related_cus_account_id, trans_amount,
    direction, trans_time, last_updated) VALUES 
( 'TRF', 'DTNBC080000002', 'DTNBC170000001', 5000, 'Debit', "2019-08-15", "2019-08-15");
-- Now add large transactionS to trigger dormant account detection
INSERT INTO TRANSACTIONS  ( 
    trans_type_id, cus_account_id, related_cus_account_id, trans_amount,
    direction, trans_time, last_updated) VALUES 
( 'TRF', 'DTNBC080000002', 'DTNBC170000001', 60000000, 'Debit', "2020-08-15", "2020-08-15"),
( 'TRF', 'DTNBC080000002', 'DTNBC170000001', 60000000, 'Debit', "2021-08-15", "2020-08-15");

select * from suspicions;
########################################################################################################################
				
                
										-- CHECK TRANSACTIONS SYSTEM --
                
                
########################################################################################################################

#######################################################################
		-- Check balance caculation & Double bookkeeping entry--
#######################################################################
-- 2025-05-17 (1 transaction) 
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('TRF', 'DTNBS250000001', 'DTNBC240000001', 1501, 'Debit', '2025-05-17 16:00:00', '2025-05-17 16:00:00'); -- Nguyễn Thị Thu Trang, Savings
SELECT * FROM CHECK_ACCOUNTS WHERE CUS_ACCOUNT_ID = 'DTNBC240000001';
SELECT * FROM SAVING_ACCOUNTS WHERE CUS_ACCOUNT_ID = 'DTNBS250000001';

SELECT * FROM TRANSACTIONS

ORDER BY trans_time DESC;  -- Sắp xếp tăng dần theo thời gian (cũ nhất lên trước)


#######################################################################
		-- Error: Wrong type of transaction for saving accounts--
#######################################################################
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('CHK', 'DTNBC170000001', NULL, 9000000, 'Credit', '2025-05-14 14:00:00', '2025-05-14 14:00:00'); -- Nguyễn Thị Thu Trang, Fixed - Transfer


#######################################################################
-- Error: Early withdrawal from Fixed Deposit Account (trigger after_insert_customer_account)--
#######################################################################
UPDATE FIXED_DEPOSIT_ACCOUNTS -- Tk check daily transfer 02
SET 
	deposit_date = '2023-05-19',
    maturity_date = '2024-05-19'
WHERE cus_account_id = 'DTNBF250000001';
select * from fixed_deposit_accounts where cus_account_id = 'DTNBF250000001';
SELECT * FROM TRANSACTIONS WHERE cus_account_id = 'DTNBF250000001';
	-- Before maturity date
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id,  trans_amount, direction, trans_time, last_updated) VALUES
('WDL', 'DTNBF250000001', 10000, 'Debit', '2024-05-15 14:00:00', '2025-05-15 14:00:00');
	-- After maturity date
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id,trans_amount, direction, trans_time, last_updated) VALUES
('WDL', 'DTNBF250000001',  15000, 'Debit', '2025-11-20 14:00:00', '2025-11-20 14:00:00');

########
