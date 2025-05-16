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
('LIMIT-002', 'DAILY TRANSACTION LIMIT EXCEEDED', 'Exceeded the daily transaction limit', TRUE, FALSE, TRUE);
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
INSERT INTO DEVICE_TYPES (device_type_name, is_portable, requires_approval, description)
VALUES
    ('Desktop', FALSE, FALSE, 'Standard device for most office-based employees (e.g., tellers, customer service, loan officers).'),
    ('Laptop', TRUE, FALSE, 'For mobile employees, managers, auditors, or IT staff who may need to work remotely or across branches.'),
    ('Thin Client', FALSE, FALSE, 'Used in highly secure environments (e.g., call centers or branch service counters).'),
    ('Mobile Device', TRUE, TRUE, 'Typically for notifications, approvals (e.g., 2FA or digital signatures by senior staff).'),
    ('Admin Console', FALSE, TRUE, 'Used by system admins or database administrators to manage internal systems.');
INSERT INTO DEVICES (device_type_id, device_name, mac_address, ip_address, is_active, is_approved, created_at, last_checked_at)
VALUES
    -- Nhân viên 101 (IT Department)
    (1, 'PC-Accounting-01', '00:1A:2B:3C:4D:5E', '192.168.1.100', TRUE, TRUE, '2023-01-15 09:00:00', '2023-12-01 14:30:00'),
    (2, 'Laptop-IT-01', '00:1A:2B:3C:4D:5F', '192.168.1.101', TRUE, TRUE, '2023-01-16 10:00:00', '2023-12-01 14:35:00'),
    -- Nhân viên 205 (Giao dịch viên)
    (2, 'VM-Accounting-Backup', '00:1A:2B:3C:4D:60', '192.168.2.50', TRUE, TRUE, '2023-02-10 08:30:00', '2023-12-01 15:00:00'),
    (4, 'Samsung Galaxy S23', '00:1A:2B:3C:4D:61', NULL, TRUE, TRUE, '2023-02-12 13:15:00', '2023-12-01 15:05:00'),
    -- Nhân viên 307 (Quản lý chi nhánh)
    (3, 'ThinClient-01', '00:1A:2B:3C:4D:62', '192.168.3.20', TRUE, TRUE, '2023-03-05 11:20:00', '2023-12-01 16:00:00');
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
select * from CUSTOMERS;

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
SELECT * FROM CUSTOMER_ACCOUNTS;

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


-- ###########################################################
-- INSERT INTO CUSTOMERS VALUES 
-- ('DTNB0101010000001', 'John', 'Doe', '1990-01-01', 'john@example.com', '123 Main St', '+84 901238881', 'Male', 'ID123456789', 'HN');
-- -- Saving Account
-- INSERT INTO CUSTOMER_ACCOUNTS VALUES ('DTNBS25000001', 'DTNB0101010000001', 'Active', NOW(), 'S');
-- UPDATE SAVING_ACCOUNTS
-- 	SET saving_acc_balance = 200000
--     WHERE cus_account_id = "DTNBS25000001" ; 
--     



-- -- Checking Account
-- INSERT INTO CUSTOMER_ACCOUNTS VALUES ('DTNBC25000001', 'DTNB0101010000001', 'Active', NOW(), 'C');
-- INSERT INTO CUSTOMER_ACCOUNTS VALUES ('DTNBC25000002', 'DTNB0101010000001', 'Active', NOW(), 'C');
-- INSERT INTO CUSTOMER_ACCOUNTS VALUES ('DTNBC25000003', 'DTNB0101010000001', 'Locked', NOW(), 'C');

-- UPDATE CHECK_ACCOUNTS
-- SET check_acc_balance = 2000000
--     WHERE cus_account_id = "DTNBC25000001" ;
-- UPDATE CHECK_ACCOUNTS
-- SET check_acc_balance = 20000000, transfer_limit = 50000000, daily_transfer_limit = 500000000
--     WHERE cus_account_id = "DTNBC25000002" ;    
-- UPDATE CHECK_ACCOUNTS
-- SET check_acc_balance = 2000000
--     WHERE cus_account_id = "DTNBC25000003" ;




-- INSERT INTO CUSTOMER_ACCOUNTS VALUES ('DTNBF25000001', 'DTNB0101010000001', 'Active', NOW(), 'F');
-- UPDATE FIXED_DEPOSIT_ACCOUNTS
-- SET deposit_amount = 2000000
--     WHERE cus_account_id = "DTNBF25000001" ;  
--     



-- -- Locked Account for testing
-- -- INSERT INTO CHECK_ACCOUNTS VALUES ('DTNBC25000003', 500000 ,1, 1000000, 100000000);
-- -- INVALID AMOUNT
-- INSERT INTO TRANSACTIONS VALUES ('TXN001', 'WDL', 'DTNBC25000002', NULL, 50900, 'Debit', NOW(), NOW(), 'Successful', NULL);
-- INSERT INTO TRANSACTIONS VALUES ('TXN002', 'TRF', 'DTNBC25000002', 'DTNBC25000002', 10000, 'Debit', NOW(), NOW(), 'Successful', NULL);
-- INSERT INTO TRANSACTIONS VALUES ('TXN003', 'TRF', 'DTNBC25000003', 'DTNBC25000002', 100000, 'Debit', NOW(), NOW(), 'Successful', NULL);
-- INSERT INTO TRANSACTIONS VALUES ('TXN005', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 8000, 'Debit', NOW(), NOW(), 'Failed', 'BAL-001');
-- INSERT INTO TRANSACTIONS VALUES ('TXN006', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 50000, 'Debit', NOW(), NOW(), 'Successful', NULL);
-- INSERT INTO TRANSACTIONS VALUES ('TXN007', 'TRF', 'DTNBC25000001', 'DTNBC25000002', 500000, 'Debit', NOW(), NOW(), 'Successful', NULL);

-- -- First, let's establish a baseline average (small transactions)
-- INSERT INTO TRANSACTIONS VALUES 
-- ('TXN008', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 100000, 'Debit', NOW(), NOW(), 'Successful', NULL),
-- ('TXN009', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 150000, 'Debit', NOW(), NOW(), 'Successful', NULL),
-- ('TXN010', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 200000, 'Debit', NOW(), NOW(), 'Successful', NULL);

-- -- Now insert a spike transaction (3x average should be ~450,000, so we'll do 500,000)
-- INSERT INTO TRANSACTIONS VALUES 
-- ('TXN011', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 500000, 'Debit', NOW(), NOW(), 'Successful', NULL);
-- -- Tạo lịch sử giao dịch 1 năm cho tài khoản DTNBC25000002
-- INSERT INTO TRANSACTIONS VALUES 
-- ('TXN029', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 1000000, 'Debit', DATE_SUB(NOW(), INTERVAL 11 MONTH), DATE_SUB(NOW(), INTERVAL 11 MONTH), 'Successful', NULL),
-- ('TXN030', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 1500000, 'Debit', DATE_SUB(NOW(), INTERVAL 10 MONTH), DATE_SUB(NOW(), INTERVAL 10 MONTH), 'Successful', NULL),
-- ('TXN031', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 2000000, 'Debit', DATE_SUB(NOW(), INTERVAL 9 MONTH), DATE_SUB(NOW(), INTERVAL 9 MONTH), 'Successful', NULL),
-- ('TXN032', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 1200000, 'Debit', DATE_SUB(NOW(), INTERVAL 8 MONTH), DATE_SUB(NOW(), INTERVAL 8 MONTH), 'Successful', NULL),
-- ('TXN033', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 1800000, 'Debit', DATE_SUB(NOW(), INTERVAL 7 MONTH), DATE_SUB(NOW(), INTERVAL 7 MONTH), 'Successful', NULL),
-- ('TXN034', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 900000, 'Debit', DATE_SUB(NOW(), INTERVAL 6 MONTH), DATE_SUB(NOW(), INTERVAL 6 MONTH), 'Successful', NULL),
-- ('TXN035', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 1100000, 'Debit', DATE_SUB(NOW(), INTERVAL 5 MONTH), DATE_SUB(NOW(), INTERVAL 5 MONTH), 'Successful', NULL),
-- ('TXN036', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 1300000, 'Debit', DATE_SUB(NOW(), INTERVAL 4 MONTH), DATE_SUB(NOW(), INTERVAL 4 MONTH), 'Successful', NULL),
-- ('TXN037', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 1700000, 'Debit', DATE_SUB(NOW(), INTERVAL 3 MONTH), DATE_SUB(NOW(), INTERVAL 3 MONTH), 'Successful', NULL),
-- ('TXN038', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 1400000, 'Debit', DATE_SUB(NOW(), INTERVAL 2 MONTH), DATE_SUB(NOW(), INTERVAL 2 MONTH), 'Successful', NULL),
-- ('TXN039', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 1600000, 'Debit', DATE_SUB(NOW(), INTERVAL 1 MONTH), DATE_SUB(NOW(), INTERVAL 1 MONTH), 'Successful', NULL);

-- -- Giao dịch bình thường gần đây (không đáng ngờ)
-- INSERT INTO TRANSACTIONS VALUES 
-- ('TXN040', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 1500000, 'Debit', DATE_SUB(NOW(), INTERVAL 1 HOUR), DATE_SUB(NOW(), INTERVAL 1 HOUR), 'Successful', NULL),
-- ('TXN041', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 1200000, 'Debit', DATE_SUB(NOW(), INTERVAL 30 MINUTE), DATE_SUB(NOW(), INTERVAL 30 MINUTE), 'Successful', NULL);
-- -- Tính toán: 
-- -- Trung bình 1 năm = ~1,400,000 VND 
-- -- 10x trung bình = 14,000,000 VND
-- -- Cần 5 giao dịch trong 15 phút tổng > 14,000,000 VND

-- -- Chuỗi giao dịch gian lận trong 15 phút
-- INSERT INTO TRANSACTIONS VALUES 
-- ('TXN042', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 14 MINUTE), DATE_SUB(NOW(), INTERVAL 14 MINUTE), 'Successful', NULL),
-- ('TXN043', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 3500000, 'Debit', DATE_SUB(NOW(), INTERVAL 12 MINUTE), DATE_SUB(NOW(), INTERVAL 12 MINUTE), 'Successful', NULL),
-- ('TXN044', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 4000000, 'Debit', DATE_SUB(NOW(), INTERVAL 10 MINUTE), DATE_SUB(NOW(), INTERVAL 10 MINUTE), 'Successful', NULL),
-- ('TXN045', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 2500000, 'Debit', DATE_SUB(NOW(), INTERVAL 8 MINUTE), DATE_SUB(NOW(), INTERVAL 8 MINUTE), 'Successful', NULL),
-- ('TXN046', 'TRF', 'DTNBC25000002', 'DTNBS25000001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 5 MINUTE), DATE_SUB(NOW(), INTERVAL 5 MINUTE), 'Successful', NULL);
-- select * from customer_accounts;
-- select * from suspicions;
-- -- Tổng: 16,000,000 VND (>10x trung bình) trong 5 giao dịch

-- -- First, create a dormant account (no transactions for >3 months)
-- INSERT INTO CUSTOMER_ACCOUNTS VALUES ('DTNBC25000004', 'DTNB0101010000001', 'Active', DATE_SUB(NOW(), INTERVAL 4 MONTH), 'C');
-- -- INSERT INTO CHECK_ACCOUNTS VALUES ('DTNBC25000004', 2000000, NULL, 50000000, 500000000);

-- -- Now add a large transaction to trigger dormant account detection
-- INSERT INTO TRANSACTIONS VALUES 
-- ('TXN018', 'TRF', 'DTNBC25000004', 'DTNBS25000001', 50000000, 'Debit', NOW(), NOW(), 'Successful', NULL);
-- -- SELECT * FROM SUSPICIONS;
-- -- SELECT * FROM saving_accounts_view;
-- -- SELECT * FROM check_accounts_view;
-- -- SELECT * FROM fixed_deposit_accounts_view;
-- -- SELECT * FROM customer_accounts_view;
-- -- select * from transactions;
-- -- select * from failed_transactions;

-- -- Thêm khách hàng mẫu
-- INSERT INTO CUSTOMERS VALUES 
-- ('CUS001', 'Nguyen', 'Van A', '1990-01-01', 'nguyenvana@email.com', '123 Đường ABC, Hà Nội', '0912345678', 'Male', '123456789012', 'HN');
-- -- Thêm tài khoản tiết kiệm
-- INSERT INTO CUSTOMER_ACCOUNTS VALUES ('ACC001', 'CUS001', 'Active', NOW(), 'S');
-- UPDATE CHECK_ACCOUNTS
-- SET check_acc_balance = 2000000
--     WHERE cus_account_id = "ACC001" ;

-- -- Thêm tài khoản thanh toán
-- INSERT INTO CUSTOMER_ACCOUNTS VALUES ('ACC002', 'CUS001', 'Active', NOW(), 'C');
-- UPDATE CHECK_ACCOUNTS
-- SET check_acc_balance = 200000000000000000
--     WHERE cus_account_id = "ACC002" ;-- Thêm tài khoản không hoạt động (dormant)

-- SELECT * FROM CUSTOMER_ACCOUNTS;
-- -- Test case 1: Giao dịch bình thường không kích hoạt trigger
-- INSERT INTO TRANSACTIONS VALUES 
-- ('TXN012', 'TRF', 'ACC002', 'ACC001', 1500000, 'Debit', NOW(), NOW(), 'Successful', NULL);

-- -- Test case 2: 5 giao dịch trong 15 phút vượt 10x trung bình (trung bình ~1.4tr, 10x = 14tr)
-- -- Lower yearly average for ACC002 by inserting small transactions
-- -- Insert small transactions (before amount spike)
-- INSERT INTO TRANSACTIONS VALUES
-- ('AS115', 'TRF', 'ACC002', 'ACC001', 100000, 'Debit', DATE_SUB(NOW(), INTERVAL 350 DAY), DATE_SUB(NOW(), INTERVAL 350 DAY), 'Successful', NULL),
-- ('AS116', 'TRF', 'ACC002', 'ACC001', 120000, 'Debit', DATE_SUB(NOW(), INTERVAL 330 DAY), DATE_SUB(NOW(), INTERVAL 330 DAY), 'Successful', NULL),
-- ('AS117', 'TRF', 'ACC002', 'ACC001', 95000,  'Debit', DATE_SUB(NOW(), INTERVAL 310 DAY), DATE_SUB(NOW(), INTERVAL 310 DAY), 'Successful', NULL),
-- ('AS118', 'TRF', 'ACC002', 'ACC001', 110000, 'Debit', DATE_SUB(NOW(), INTERVAL 290 DAY), DATE_SUB(NOW(), INTERVAL 290 DAY), 'Successful', NULL),
-- ('AS119', 'TRF', 'ACC002', 'ACC001', 105000, 'Debit', DATE_SUB(NOW(), INTERVAL 270 DAY), DATE_SUB(NOW(), INTERVAL 270 DAY), 'Successful', NULL),
-- ('AS120', 'TRF', 'ACC002', 'ACC001', 98000,  'Debit', DATE_SUB(NOW(), INTERVAL 240 DAY), DATE_SUB(NOW(), INTERVAL 240 DAY), 'Successful', NULL),
-- ('AS121', 'TRF', 'ACC002', 'ACC001', 102000, 'Debit', DATE_SUB(NOW(), INTERVAL 220 DAY), DATE_SUB(NOW(), INTERVAL 220 DAY), 'Successful', NULL),
-- ('AS122', 'TRF', 'ACC002', 'ACC001', 100000, 'Debit', DATE_SUB(NOW(), INTERVAL 200 DAY), DATE_SUB(NOW(), INTERVAL 200 DAY), 'Successful', NULL),
-- ('AS123', 'TRF', 'ACC002', 'ACC001', 99000,  'Debit', DATE_SUB(NOW(), INTERVAL 180 DAY), DATE_SUB(NOW(), INTERVAL 180 DAY), 'Successful', NULL),
-- ('AS124', 'TRF', 'ACC002', 'ACC001', 97000,  'Debit', DATE_SUB(NOW(), INTERVAL 160 DAY), DATE_SUB(NOW(), INTERVAL 160 DAY), 'Successful', NULL),
-- ('AS125', 'TRF', 'ACC002', 'ACC001', 103000, 'Debit', DATE_SUB(NOW(), INTERVAL 140 DAY), DATE_SUB(NOW(), INTERVAL 140 DAY), 'Successful', NULL),
-- ('AS126', 'TRF', 'ACC002', 'ACC001', 101000, 'Debit', DATE_SUB(NOW(), INTERVAL 120 DAY), DATE_SUB(NOW(), INTERVAL 120 DAY), 'Successful', NULL),
-- ('AS127', 'TRF', 'ACC002', 'ACC001', 95000,  'Debit', DATE_SUB(NOW(), INTERVAL 100 DAY), DATE_SUB(NOW(), INTERVAL 100 DAY), 'Successful', NULL),
-- ('AS128', 'TRF', 'ACC002', 'ACC001', 98000,  'Debit', DATE_SUB(NOW(), INTERVAL 80 DAY), DATE_SUB(NOW(), INTERVAL 80 DAY), 'Successful', NULL),
-- ('AS129', 'TRF', 'ACC002', 'ACC001', 99000,  'Debit', DATE_SUB(NOW(), INTERVAL 60 DAY), DATE_SUB(NOW(), INTERVAL 60 DAY), 'Successful', NULL),
-- ('AS130', 'TRF', 'ACC002', 'ACC001', 96000,  'Debit', DATE_SUB(NOW(), INTERVAL 40 DAY), DATE_SUB(NOW(), INTERVAL 40 DAY), 'Successful', NULL),
-- ('AS131', 'TRF', 'ACC002', 'ACC001', 97000,  'Debit', DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY), 'Successful', NULL);

-- -- Insert the large spike transactions (these should come after the small ones)
-- INSERT INTO TRANSACTIONS VALUES
-- ('AS132', 'TRF', 'ACC002', 'ACC001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 15 MINUTE), DATE_SUB(NOW(), INTERVAL 15 MINUTE), 'Successful', NULL),
-- ('AS133', 'TRF', 'ACC002', 'ACC001', 3500000, 'Debit', DATE_SUB(NOW(), INTERVAL 12 MINUTE), DATE_SUB(NOW(), INTERVAL 12 MINUTE), 'Successful', NULL),
-- ('AS134', 'TRF', 'ACC002', 'ACC001', 4000000, 'Debit', DATE_SUB(NOW(), INTERVAL 11 MINUTE), DATE_SUB(NOW(), INTERVAL 10 MINUTE), 'Successful', NULL),
-- ('AS135', 'TRF', 'ACC002', 'ACC001', 2500000, 'Debit', DATE_SUB(NOW(), INTERVAL 9 MINUTE), DATE_SUB(NOW(), INTERVAL 8 MINUTE), 'Successful', NULL),
-- ('AS136', 'TRF', 'ACC002', 'ACC001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 8 MINUTE), DATE_SUB(NOW(), INTERVAL 5 MINUTE), 'Successful', NULL),
-- ('AS137', 'TRF', 'ACC002', 'ACC001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 7 MINUTE), DATE_SUB(NOW(), INTERVAL 3 MINUTE), 'Successful', NULL),
-- ('AS138', 'TRF', 'ACC002', 'ACC001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 6 MINUTE), DATE_SUB(NOW(), INTERVAL 2 MINUTE), 'Successful', NULL),
-- ('AS139', 'TRF', 'ACC002', 'ACC001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 5 MINUTE), DATE_SUB(NOW(), INTERVAL 5 MINUTE), 'Successful', NULL),
-- ('AS140', 'TRF', 'ACC002', 'ACC001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 4 MINUTE), DATE_SUB(NOW(), INTERVAL 3 MINUTE), 'Successful', NULL),
-- ('AS141', 'TRF', 'ACC002', 'ACC001', 3000000, 'Debit', DATE_SUB(NOW(), INTERVAL 2 MINUTE), DATE_SUB(NOW(), INTERVAL 2 MINUTE), 'Successful', NULL);

-- -- Tạo khách hàng mới
-- select * from debug_log;

-- -- Gắn tài khoản với khách hàng
-- INSERT INTO CUSTOMER_ACCOUNTS (
--     cus_account_id, cus_id, cus_account_status, cus_account_type_id
-- )
-- VALUES (
--     'ACC003', 'CUS001', 'Active', 'C'
-- );
-- UPDATE CHECK_ACCOUNTS
-- SET check_acc_balance = 200000000
--     WHERE cus_account_id = "ACC003" ;
-- INSERT INTO TRANSACTIONS (
--     trans_id, trans_type_id, cus_account_id, related_cus_account_id, trans_amount,
--     direction, trans_time, last_updated, trans_status
-- )
-- VALUES (
--     'AS301', 'TRF', 'ACC003', 'ACC001', 100000, 'Debit',
--     DATE_SUB(NOW(), INTERVAL 100 DAY), DATE_SUB(NOW(), INTERVAL 100 DAY), 'Successful'
-- );
-- INSERT INTO TRANSACTIONS (
--     trans_id, trans_type_id, cus_account_id, related_cus_account_id, trans_amount,
--     direction, trans_time, last_updated, trans_status
-- )
-- VALUES (
--     'AS302', 'TRF', 'ACC003', 'ACC001', 80000000, 'Debit',
--     NOW(), NOW(), 'Successful'
-- );
-- select * from debug_log_2;
-- select * from TEMP_suspicions;
-- select * from suspicions;

-- SELECT count(*)
-- FROM SUSPICIONS s
-- JOIN TRANSACTIONS t ON s.trans_id = t.trans_id
-- WHERE t.cus_account_id = 'ACC002'
-- 	AND s.severity_level = 'High'
--     AND s.suspicion_status != 'False_positive';



-- -- INSERT INTO CHECK_ACCOUNTS VALUES ('DTNBC25000011', 50000000 ,1, 100000, 1000000);
-- -- INSERT INTO TRANSACTIONS VALUES ('TXN007', 'TRF', 'DTNBC25000011', 'DTNBS25000001', 500000, 'Debit', NOW(), NOW(), 'Successful', NULL);


