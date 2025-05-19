use main;

###############################################################################################################################
INSERT INTO BRANCHES (branch_id, branch_name, branch_address) VALUES
('HN', 'Hanoi', '123 Lang Street, Dong Da District, Hanoi'),
('HCM', 'Ho Chi Minh City', '456 Le Loi Street, District 1, Ho Chi Minh City'),
('DN', 'Da Nang', '789 Nguyen Van Linh Street, Hai Chau District, Da Nang'),
('QN', 'Quang Ninh', '321 Tran Hung Dao Street, Ha Long City, Quang Ninh'),
('HP', 'Hai Phong', '101 Lach Tray Street, Ngo Quyen District, Hai Phong');

INSERT INTO TRANSACTION_TYPES (trans_type_id, trans_type_name, description)
VALUES
    ('POS', 'Point of Sale', 'Debit/credit card purchases at stores, online payments. Extremely frequent in retail banking.'),
    ('DEP', 'Deposit', 'Includes salary credit, cash deposits, check deposits.'),
    ('WDL', 'Withdrawal', 'ATM cash withdrawals or over-the-counter withdrawals.'),
    ('TRF', 'Transfer', 'Transfers between personal accounts or to other people/banks.'),
    ('PMT', 'Payment', 'Loan repayments, utility bill payments, subscriptions.'),
    ('ACH', 'Automated Clearing House', 'Payroll, insurance, recurring payments (e.g., Netflix, insurance).'),
    ('INT', 'Interest Credit', 'Monthly or quarterly interest accruals on savings accounts.'),
    ('FEE', 'Fee Charge', 'Service charges, ATM fees, late fees, etc.'),
    ('CHK', 'Check', 'Used more in business or older accounts (declining in use).'),
    ('REF', 'Refund', 'E-commerce or billing refunds (increasing in usage).');
INSERT INTO CUSTOMER_ACCOUNT_TYPES VALUES 
('S', 'Saving Account'),
('C', 'Checking Account'),
('F', 'Fixed Deposit Account');
INSERT INTO TRANSACTION_ERROR_CODES VALUES
('VAL-001', 'SAME ACCOUNT', 'Source and destination accounts are the same', TRUE, TRUE, FALSE),
('VAL-002', 'INVALID ACCOUNT', 'Destination accounts is invalid', TRUE, TRUE, FALSE),
('ACC-001', 'DESTINATION ACCOUNT LOCKED', 'The destination account has been locked', TRUE, FALSE, TRUE),
('BAL-001', 'INSUFFICIENT BALANCE', 'Insufficient account balance', TRUE, TRUE, FALSE),
('LIMIT-001', 'TRANSACTION LIMIT EXCEEDED', 'Exceeded the transaction limit', TRUE, FALSE, TRUE),
('LIMIT-002', 'DAILY TRANSACTION LIMIT EXCEEDED', 'Exceeded the daily transaction limit', TRUE, FALSE, TRUE),
('EWP', 'EARLY WITHDRAWAL PENALTY', 'Penalty charged for early withdrawal before maturity',  TRUE, FALSE, TRUE);
INSERT INTO INTEREST_RATES (interest_rate_val, cus_account_type_id, min_balance, max_balance, status, term)
VALUES
(0.1, 'C', 0, NULL, 'Active', NULL),
(1.9, 'S', 100000, 1000000000, 'Active', NULL),
(4.8, 'F', 1000000, NULL, 'Active', 1),
(5.2, 'F', 1000000, NULL, 'Active', 6),
(5.5, 'F', 1000000, NULL, 'Inactive', 12);
INSERT INTO SERVICE_TYPES (service_type_id, service_name, description)
VALUES
    -- Core Banking Service Groups
    ('ACCT', 'Account Services', 'Opening, closing, and managing customer accounts'),
    ('CARD', 'Card Services', 'Issuance and management of debit/credit cards'),
    ('LOAN', 'Loan Services', 'Processing and management of loan products'),
    ('TRAN', 'Transaction Services', 'Handling deposits, withdrawals, and transfers'),
    ('CUST', 'Customer Support', 'Resolving inquiries and complaints'),
    ('OPS', 'Internal Operations', 'Back-office processes and reconciliations'),
    ('DIGI', 'Digital Banking', 'Online and mobile banking services'),
    ('INVT', 'Investment Services', 'Wealth management and investment products'),
    ('INSR', 'Insurance Services', 'Bank-linked insurance offerings'),
    ('COMP', 'Compliance Reporting', 'Regulatory and anti-fraud operations');
INSERT INTO EMPLOYEE_POSITIONS (emp_position_id, emp_position_name, description)
VALUES 
('T', 'Teller', 'Handles daily banking transactions'),
('M', 'Manager', 'Manages bank branch operations'),
('A', 'Auditor', 'Responsible for reviewing and auditing financial records'),
('C', 'CEO', 'Leads the entire bank, responsible for corporate strategy and executive decisions');

INSERT INTO FRAUD_PATTERNS (fraud_pattern_name, description)
VALUES 
('Transaction Amount Spike', 'More than 5 consecutive transaction in less than 15 minutes exceeds 10 times the average amount of that account over 1-year interval.(if these transaction amounts exceed 50000000'),
('Dormant Account Activity', 'An account that has not had transactions for more than 3 months suddenly has a large transaction. From 50,000,000');

######################################################
			-- CUSTOMERS --
######################################################
INSERT INTO CUSTOMERS (
    cus_first_name, cus_last_name, cus_dob, cus_email, cus_address,
    cus_phone_num, cus_sex, cus_identification_id, cus_join_date, branch_id
) VALUES
('Nguyễn Văn', 'An', '1990-05-15', 'an.nguyenvan@gmail.com', '12 Lang Ha Street, Dong Da District, Hanoi', '+84 98 765 4321', 'Male', '012345678901', '2022-06-01', 'HN'),
('Trần Thị', 'Bích', '1985-08-20', 'bich.tranth@gmail.com', '45 Nguyen Thi Minh Khai Street, District 1, Ho Chi Minh City', '+84 91 234 5678', 'Female', '023456789012', '2023-07-15', 'HCM'),
('Lê Văn', 'Cường', '1995-03-10', 'cuong.levan95@gmail.com', '89 Le Duan Street, Hai Chau District, Da Nang', '+84 92 345 6789', 'Male', '034567890123', '2013-06-11', 'DN'),
('Phạm Vân', 'Thư', '1992-07-25', 'thu.phamvan92@gmail.com', '134 Tran Quoc Nghien Street, Ha Long City, Quang Ninh', '+84 96 112 2334', 'Female', '045678901234', '2021-12-27', 'QN'),
('Nguyễn Phương', 'Đông', '1988-12-01', 'dong.nguyenphuong88@gmail.com', '210 Lach Tray Street, Ngo Quyen District, Hai Phong', '+84 97 998 8776', 'Male', '056789012345', '2023-01-01', 'HP'),
('Lê Ngọc', 'Bích', '1993-11-18', 'bich.lengoc93@gmail.com', '18 Giang Vo Street, Ba Dinh District, Hanoi', '+84 90 567 8912', 'Female', '067890123456', '2003-10-01', 'HN'),
('Hoàng Thị Thanh', 'Nhàn', '1980-04-30', 'nhan.hoangthithanh80@gmail.com', '20 Kim Ma Street, Ba Dinh District, Hanoi', '+84 93 456 7890', 'Female', '078901234567', '2003-06-01', 'HN');
INSERT INTO CUSTOMERS (
    cus_first_name, cus_last_name, cus_dob, cus_email, cus_address,
    cus_phone_num, cus_sex, cus_identification_id, branch_id
) VALUES
('Nguyễn Thị Thu', 'Trang', '1997-09-05', 'trang.nguyenthithu97@gmail.com', '67 Le Van Sy Street, District 3, Ho Chi Minh City', '+84 91 123 4567', 'Female', '089012345678', 'HCM');


######################################################
			-- CUSTOMER ACCOUNTS --
######################################################
-- Nguyễn Văn An (HN): đầy đủ 3 loại 
INSERT INTO CUSTOMER_ACCOUNTS (cus_id, cus_account_status, cus_account_type_id, opening_date) VALUES
('DTNBHN220000001', 'Active', 'S', '2022-06-01'),
('DTNBHN220000001', 'Active', 'C', '2022-06-01'),
('DTNBHN220000001', 'Active', 'F', '2023-06-11');

-- Trần Thị Bích (HCM): có tiết kiệm + thanh toán
INSERT INTO CUSTOMER_ACCOUNTS (cus_id, cus_account_status, cus_account_type_id, opening_date) VALUES
('DTNBHCM230000001', 'Active', 'S','2023-06-01'),
('DTNBHCM230000001', 'Active', 'C', '2024-06-01');
-- Lê Văn Cường (DN): trẻ, chỉ có thanh toán
INSERT INTO CUSTOMER_ACCOUNTS (cus_id, cus_account_status, cus_account_type_id, opening_date) VALUES
('DTNBDN130000001', 'Active', 'C', '2013-06-01');
-- Phạm Vân Thư (QN): có tiết kiệm + tài khoản thanh toán bị khóa
INSERT INTO CUSTOMER_ACCOUNTS (cus_id, cus_account_status, cus_account_type_id, opening_date) VALUES
('DTNBQN210000001', 'Active', 'S', '2022-06-21'),
('DTNBQN210000001', 'Temporarily Locked', 'C', '2024-06-01');
-- Nguyễn Phương Đông (HP): chỉ gửi có kỳ hạn (Fixed)
INSERT INTO CUSTOMER_ACCOUNTS (cus_id, cus_account_status, cus_account_type_id, opening_date) VALUES
('DTNBHP230000001', 'Active', 'F', '2023-06-01');
-- Lê Ngọc Bích (HN): tiết kiệm + thanh toán
INSERT INTO CUSTOMER_ACCOUNTS (cus_id, cus_account_status, cus_account_type_id, opening_date) VALUES
('DTNBHN030000001', 'Active', 'S', '2003-06-01'),
('DTNBHN030000001', 'Active', 'C', '2012-06-01'),
('DTNBHN030000001', 'Active', 'C', '2022-06-01');
-- Hoàng Thị Thanh Nhàn (HN): chỉ tiết kiệm
INSERT INTO CUSTOMER_ACCOUNTS (cus_id, cus_account_status, cus_account_type_id, opening_date) VALUES
('DTNBHN030000002', 'Active', 'S', '2003-06-01');
-- Nguyễn Thị Thu Trang (HCM): tiết kiệm + có kỳ hạn
INSERT INTO CUSTOMER_ACCOUNTS (cus_id, cus_account_status, cus_account_type_id) VALUES
('DTNBHCM250000001', 'Active', 'S'),
('DTNBHCM250000001', 'Active', 'F');


UPDATE SAVING_ACCOUNTS
SET saving_acc_balance = CASE cus_account_id
    WHEN 'DTNBS030000001' THEN 50000000
    WHEN 'DTNBS030000002' THEN 6000000
    WHEN 'DTNBS220000001' THEN 1000000
    WHEN 'DTNBS220000002' THEN 2000000
    WHEN 'DTNBS230000001' THEN 3000000
    WHEN 'DTNBS250000001' THEN 4000000
    ELSE saving_acc_balance
END;
UPDATE CHECK_ACCOUNTS
SET 
    check_acc_balance = CASE cus_account_id
        WHEN 'DTNBC120000001' THEN 7000000
        WHEN 'DTNBC130000001' THEN 8000000
        WHEN 'DTNBC220000001' THEN 9000000
        WHEN 'DTNBC220000002' THEN 6000000
        WHEN 'DTNBC240000001' THEN 7500000
        WHEN 'DTNBC240000002' THEN 8500000
        ELSE check_acc_balance
    END,
    
    daily_transfer_limit = CASE cus_account_id
        WHEN 'DTNBC120000001' THEN 20000000
        WHEN 'DTNBC130000001' THEN 25000000
        WHEN 'DTNBC220000001' THEN 30000000
        WHEN 'DTNBC220000002' THEN 15000000
        WHEN 'DTNBC240000001' THEN 10000000
        WHEN 'DTNBC240000002' THEN 5000000
        ELSE daily_transfer_limit
    END;
UPDATE FIXED_DEPOSIT_ACCOUNTS
SET deposit_amount = CASE cus_account_id
    WHEN 'DTNBF230000001' THEN 10000000
    WHEN 'DTNBF230000002' THEN 15000000
    WHEN 'DTNBF250000001' THEN 20000000
    ELSE deposit_amount
END;

######################################################
			-- EMPLOYEES --
######################################################            
INSERT INTO EMPLOYEES (emp_fullname, emp_sex, emp_dob, emp_phone_num, emp_email, emp_address,  branch_id, emp_position_id, emp_join_date) VALUES
('Hoàng Ngọc Phương Vân', 'Female', '1970-01-01', '+84 986898689', 'ceo.hn@bank.com', '99 Phan Đình Phùng, Hà Nội',  'HN', 'C', '2010-01-15');
INSERT INTO EMPLOYEES (emp_fullname, emp_sex, emp_dob, emp_phone_num, emp_email, emp_address, emp_salary, branch_id, emp_position_id, emp_join_date) 
VALUES 
('Hoàng Thị Thanh Cuctar', 'Male', '1982-06-15', '+84 900000002', 'manager1.hn@bank.com', '15 Lý Thái Tổ, Hà Nội', 25000000, 'HN', 'M', '2015-03-10'),
('Trần Thị Quản Lý 2', 'Female', '1983-09-20', '+84 900000003', 'manager2.hn@bank.com', '23 Trần Hưng Đạo, Hà Nội', 25000000, 'HN', 'M', '2016-05-20'),
('Nguyễn Thị Giao Dịch 1', 'Female', '1990-01-10', '+84 900000004', 'teller1.hn@bank.com', '45 Đinh Tiên Hoàng, Hà Nội', 12000000, 'HN', 'T', '2018-02-15'),
('Trần Thị Giao Dịch 2', 'Female', '1992-03-25', '+84 900000005', 'teller2.hn@bank.com', '68 Tràng Thi, Hà Nội', 12000000, 'HN', 'T', '2019-04-05'),
('Lê Thị Giao Dịch 3', 'Female', '1993-07-11', '+84 900000006', 'teller3.hn@bank.com', '72 Lê Duẩn, Hà Nội', 12000000, 'HN', 'T', '2019-07-22'),
('Vũ Quang Giao Dịch 4', 'Male', '1991-05-20', '+84 900000007', 'teller4.hn@bank.com', '92 Nguyễn Du, Hà Nội', 12000000, 'HN', 'T', '2020-01-10'),
('Nguyễn Thị Giao Dịch 5', 'Female', '1994-11-30', '+84 900000008', 'teller5.hn@bank.com', '104 Bà Triệu, Hà Nội', 12000000, 'HN', 'T', '2020-03-18'),
('Lê Minh Giao Dịch 6', 'Male', '1991-10-10', '+84 900000009', 'teller6.hn@bank.com', '115 Nguyễn Thái Học, Hà Nội', 12000000, 'HN', 'T', '2020-06-30'),
('Trần Minh Giao Dịch 7', 'Male', '1990-12-01', '+84 900000010', 'teller7.hn@bank.com', '124 Phan Bội Châu, Hà Nội', 12000000, 'HN', 'T', '2021-02-14'),
('Nguyễn Minh Giao Dịch 8', 'Male', '1992-08-21', '+84 900000011', 'teller8.hn@bank.com', '135 Cầu Giấy, Hà Nội', 12000000, 'HN', 'T', '2021-05-20'),
('Nguyễn Quang Kiểm Toán 1', 'Male', '1984-03-15', '+84 900000012', 'auditor1.hn@bank.com', '150 Trường Chinh, Hà Nội', 18000000, 'HN', 'A', '2017-08-15'),
('Lê Quang Kiểm Toán 2', 'Male', '1985-06-25', '+84 900000013', 'auditor2.hn@bank.com', '160 Nguyễn Chí Thanh, Hà Nội', 17500000, 'HN', 'A', '2018-09-10'),
('Vũ Thị Kiểm Toán 3', 'Female', '1986-09-10', '+84 900000014', 'auditor3.hn@bank.com', '172 Trương Định, Hà Nội', 17000000, 'HN', 'A', '2019-11-05');

-- Chi nhánh Hồ Chí Minh - 6 nhân viên
INSERT INTO EMPLOYEES (emp_fullname, emp_sex, emp_dob, emp_phone_num, emp_email, emp_address, emp_salary, branch_id, emp_position_id, emp_join_date) VALUES
('Lee Ngọc Peach', 'Female', '1982-03-20', '+84 900000015', 'manager.hcm@bank.com', '55 Nguyễn Thị Minh Khai, HCM', 25000000, 'HCM', 'M', '2016-04-12'),
('Nguyễn Thị Giao Dịch 1', 'Female', '1990-11-30', '+84 900000016', 'teller1.hcm@bank.com', '45 Lê Lợi, HCM', 12000000, 'HCM', 'T', '2019-03-15'),
('Lê Minh Giao Dịch 2', 'Male', '1992-04-18', '+84 900000017', 'teller2.hcm@bank.com', '60 Cách Mạng Tháng 8, HCM', 12000000, 'HCM', 'T', '2019-06-20'),
('Phạm Thị Giao Dịch 3', 'Female', '1993-07-22', '+84 900000018', 'teller3.hcm@bank.com', '77 Nguyễn Huệ, HCM', 12000000, 'HCM', 'T', '2020-01-10'),
('Vũ Minh Giao Dịch 4', 'Male', '1991-05-14', '+84 900000019', 'teller4.hcm@bank.com', '89 Lý Tự Trọng, HCM', 12000000, 'HCM', 'T', '2020-03-25'),
('Nguyễn Quang Giao Dịch 5', 'Male', '1990-02-17', '+84 900000020', 'teller5.hcm@bank.com', '102 Đề Thám, HCM', 12000000, 'HCM', 'T', '2020-05-30'),
('Trương Thị Kiểm Toán 1', 'Female', '1984-07-10', '+84 900000021', 'auditor1.hcm@bank.com', '35 Nam Kỳ Khởi Nghĩa, HCM', 18000000, 'HCM', 'A', '2018-02-15'),
('Lê Thị Kiểm Toán 2', 'Female', '1986-11-15', '+84 900000022', 'auditor2.hcm@bank.com', '112 Đồng Khởi, HCM', 17500000, 'HCM', 'A', '2019-04-20');

-- Chi nhánh Đà Nẵng - 6 nhân viên
INSERT INTO EMPLOYEES(emp_fullname, emp_sex, emp_dob, emp_phone_num, emp_email, emp_address, emp_salary, branch_id, emp_position_id, emp_join_date) VALUES
('Nguyễn Văn Quản Lý', 'Male', '1984-02-20', '+84 900000023', 'manager.dn@bank.com', '12 Lê Duẩn, Đà Nẵng', 25000000, 'DN', 'M', '2017-05-10'),
('Trần Thị Giao Dịch 1', 'Female', '1990-11-15', '+84 900000024', 'teller1.dn@bank.com', '34 Hùng Vương, Đà Nẵng', 12000000, 'DN', 'T', '2019-08-12'),
('Lê Thị Giao Dịch 2', 'Female', '1993-05-30', '+84 900000025', 'teller2.dn@bank.com', '56 Trần Phú, Đà Nẵng', 12000000, 'DN', 'T', '2020-02-18'),
('Vũ Thị Giao Dịch 3', 'Female', '1994-08-14', '+84 900000026', 'teller3.dn@bank.com', '89 Lý Tự Trọng, Đà Nẵng', 12000000, 'DN', 'T', '2020-06-22'),
('Nguyễn Quang Giao Dịch 4', 'Male', '1991-07-18', '+84 900000027', 'teller4.dn@bank.com', '102 Nguyễn Hữu Thọ, Đà Nẵng', 12000000, 'DN', 'T', '2021-01-15'),
('Phạm Thị Giao Dịch 5', 'Female', '1992-03-20', '+84 900000028', 'teller5.dn@bank.com', '121 Phan Châu Trinh, Đà Nẵng', 12000000, 'DN', 'T', '2021-03-10'),
('Trương Quang Kiểm Toán 1', 'Male', '1985-09-12', '+84 900000029', 'auditor1.dn@bank.com', '45 Bạch Đằng, Đà Nẵng', 18000000, 'DN', 'A', '2018-10-05'),
('Lê Quang Kiểm Toán 2', 'Male', '1986-03-17', '+84 900000030', 'auditor2.dn@bank.com', '67 Hải Châu, Đà Nẵng', 17500000, 'DN', 'A', '2019-07-20');

-- Chi nhánh Hải Phòng - 5 nhân viên
INSERT INTO EMPLOYEES (emp_fullname, emp_sex, emp_dob, emp_phone_num, emp_email, emp_address, emp_salary, branch_id, emp_position_id, emp_join_date) VALUES
('Nguyễn Phương Dongiz', 'Female', '1981-11-30', '+84 900000031', 'manager.hp@bank.com', '123 Trần Phú, Hải Phòng', 25000000, 'HP', 'M', '2018-03-15'),
('Nguyễn Thị Giao Dịch 1', 'Female', '1992-05-12', '+84 900000032', 'teller1.hp@bank.com', '45 Lạch Tray, Hải Phòng', 12000000, 'HP', 'T', '2020-04-10'),
('Võ Thị Giao Dịch 2', 'Female', '1993-11-03', '+84 900000033', 'teller2.hp@bank.com', '68 Ngô Quyền, Hải Phòng', 12000000, 'HP', 'T', '2020-07-25'),
('Đặng Thị Giao Dịch 3', 'Female', '1991-10-17', '+84 900000034', 'teller3.hp@bank.com', '101 Cầu Đất, Hải Phòng', 12000000, 'HP', 'T', '2021-02-18'),
('Lê Minh Giao Dịch 4', 'Male', '1990-07-22', '+84 900000035', 'teller4.hp@bank.com', '25 Lê Chân, Hải Phòng', 12000000, 'HP', 'T', '2021-05-30'),
('Trần Quang Giao Dịch 5', 'Male', '1992-09-03', '+84 900000036', 'teller5.hp@bank.com', '77 Tôn Đức Thắng, Hải Phòng', 12000000, 'HP', 'T', '2021-08-15'),
('Vũ Thị Kiểm Toán 1', 'Female', '1984-12-13', '+84 900000037', 'auditor1.hp@bank.com', '99 Hoàng Minh Giám, Hải Phòng', 18000000, 'HP', 'A', '2019-06-20'),
('Nguyễn Thị Kiểm Toán 2', 'Female', '1985-08-21', '+84 900000038', 'auditor2.hp@bank.com', '134 Đinh Tiên Hoàng, Hải Phòng', 17500000, 'HP', 'A', '2020-01-10');

-- Chi nhánh Quảng Ninh - 5 nhân viên
INSERT INTO EMPLOYEES (emp_fullname, emp_sex, emp_dob, emp_phone_num, emp_email, emp_address, emp_salary, branch_id, emp_position_id, emp_join_date) VALUES
('Phạm Vân Thư', 'Female', '1983-04-15', '+84 900000039', 'manager.qn@bank.com', '34 Quang Trung, Quảng Ninh', 25000000, 'QN', 'M', '2019-02-10'),
('Phạm Văn Giao Dịch 1', 'Male', '1991-06-25', '+84 900000040', 'teller1.qn@bank.com', '45 Nguyễn Huệ, Quảng Ninh', 12000000, 'QN', 'T', '2020-05-15'),
('Lê Quang Giao Dịch 2', 'Male', '1992-02-18', '+84 900000041', 'teller2.qn@bank.com', '58 Hoàng Quốc Việt, Quảng Ninh', 12000000, 'QN', 'T', '2020-08-20'),
('Nguyễn Thị Giao Dịch 3', 'Female', '1993-11-29', '+84 900000042', 'teller3.qn@bank.com', '72 Cầu Đen, Quảng Ninh', 12000000, 'QN', 'T', '2021-01-12'),
('Trần Minh Giao Dịch 4', 'Male', '1990-08-11', '+84 900000043', 'teller4.qn@bank.com', '99 Cái Dăm, Quảng Ninh', 12000000, 'QN', 'T', '2021-04-05'),
('Vũ Minh Giao Dịch 5', 'Male', '1992-04-20', '+84 900000044', 'teller5.qn@bank.com', '23 Lý Thường Kiệt, Quảng Ninh', 12000000, 'QN', 'T', '2021-07-18'),
('Nguyễn Quang Kiểm Toán 1', 'Male', '1985-07-30', '+84 900000045', 'auditor1.qn@bank.com', '67 Cái Dăm, Quảng Ninh', 18000000, 'QN', 'A', '2020-03-10'),
('Lê Thị Kiểm Toán 2', 'Female', '1986-05-05', '+84 900000046', 'auditor2.qn@bank.com', '123 Bãi Cháy, Quảng Ninh', 17500000, 'QN', 'A', '2020-09-15');

INSERT INTO employee_accounts (emp_id, username, password_hash, status, suspension_time, reactivation_time, created_at
) VALUES
('HNA180001', 'toan1', SHA2('toan1', 256), 'Active', NULL, NULL, '2018-09-10 00:00:00'),
('HNA190001', 'toan2', SHA2('toan2', 256), 'Active', NULL, NULL, '2019-11-05 00:00:00'),
('HNC100001', 'van',   SHA2('van', 256), 'Active', NULL, NULL, '2010-01-15 00:00:00'),
('HNM150001', 'nhan',  SHA2('nhan', 256), 'Active', NULL, NULL, '2015-03-10 00:00:00'),
('HNM160001', 'chau',  SHA2('chau', 256), 'Active', NULL, NULL, '2016-05-20 00:00:00'),
('HNT180001', 'nam',   SHA2('nam', 256), 'Active', NULL, NULL, '2018-02-15 00:00:00'),
('HNT190001', 'gdich1', SHA2('gdich1', 256), 'Active', NULL, NULL, '2018-02-15 00:00:00'),
('HNT200001', 'gdich2', SHA2('gdich2', 256), 'Active', NULL, NULL, '2018-02-15 00:00:00');

INSERT INTO EMPLOYEE_CUSTOMERS (emp_id, cus_id, service_type_id, assigned_date) VALUES
('HNT180001', 'DTNBHN030000001', 'ACCT', '2023-11-01'),
('HNT190001', 'DTNBHN030000002', 'LOAN', '2023-07-15'),
('HNT190002', 'DTNBHN220000001', 'CARD', '2022-07-01'),
('HCMT190001', 'DTNBHCM230000001', 'ACCT', '2023-08-01'),
('HCMT190002', 'DTNBHCM250000001', 'DIGI', '2025-05-01'),
('DNT190001', 'DTNBDN130000001', 'CARD', '2023-07-01'),
('HPT200001', 'DTNBHP230000001', 'TRAN', '2023-02-01'),
('QNT200001', 'DTNBQN210000001', 'LOAN', '2022-01-15'),
('HCMT200001', 'DTNBHCM230000001', 'CARD', '2023-09-15'),
('DNT200001', 'DTNBDN130000001', 'ACCT', '2023-08-10'),
('QNT210001', 'DTNBQN210000001', 'DIGI', '2022-02-01'),
('HNA170001', 'DTNBHN220000001', 'COMP', '2023-03-01'),
('HCMA180001', 'DTNBHCM250000001', 'COMP', '2025-05-10');
