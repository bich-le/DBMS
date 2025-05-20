use main;
-- 2013-07-01 (1 transaction)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('POS', 'DTNBC130000001', NULL, 1300000, 'Debit', '2013-07-01 09:00:00', '2013-07-01 09:00:00'); -- Lê Văn Cường, Checking

-- 2014-01-01 (1 transaction)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('POS', 'DTNBC130000001', NULL, 1400000, 'Debit', '2014-01-01 10:00:00', '2014-01-01 10:00:00'); -- Lê Văn Cường, Checking

-- 2022-07-01 (4 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('POS', 'DTNBC220000001', NULL, 1500000, 'Debit', '2022-07-01 09:00:00', '2022-07-01 09:00:00'), -- Nguyễn Văn An, Checking
('DEP', 'DTNBS220000001', NULL, 5000000, 'Credit', '2022-07-01 09:00:00', '2022-07-01 09:00:00'), -- Nguyễn Văn An, Savings
('POS', 'DTNBC120000001', NULL, 1500000, 'Debit', '2022-07-01 09:00:00', '2022-07-01 09:00:00'), -- Lê Ngọc Bích, Checking
('POS', 'DTNBC220000002', NULL, 1200000, 'Debit', '2022-07-01 09:00:00', '2022-07-01 09:00:00'); -- Lê Ngọc Bích, Checking

-- 2022-08-01 (3 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('POS', 'DTNBC220000001', NULL, 2000000, 'Debit', '2022-08-01 10:00:00', '2022-08-01 10:00:00'), -- Nguyễn Văn An, Checking
('DEP', 'DTNBS220000001', NULL, 3000000, 'Credit', '2022-08-01 10:00:00', '2022-08-01 10:00:00'), -- Nguyễn Văn An, Savings
('POS', 'DTNBC120000001', NULL, 1300000, 'Debit', '2022-08-01 10:00:00', '2022-08-01 10:00:00'); -- Lê Ngọc Bích, Checking

-- 2022-09-01 (2 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('POS', 'DTNBC220000001', NULL, 1000000, 'Debit', '2022-09-01 11:00:00', '2022-09-01 11:00:00'), -- Nguyễn Văn An, Checking
('POS', 'DTNBC220000002', NULL, 1400000, 'Debit', '2022-09-01 11:00:00', '2022-09-01 11:00:00'); -- Lê Ngọc Bích, Checking

-- 2022-10-01 (2 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('POS', 'DTNBC220000001', NULL, 1200000, 'Debit', '2022-10-01 12:00:00', '2022-10-01 12:00:00'), -- Nguyễn Văn An, Checking
('POS', 'DTNBC120000001', NULL, 1300000, 'Debit', '2022-10-01 12:00:00', '2022-10-01 12:00:00'); -- Lê Ngọc Bích, Checking

-- 2022-11-01 (2 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('WDL', 'DTNBC220000001', NULL, 1000000, 'Debit', '2022-11-01 13:00:00', '2022-11-01 13:00:00'), -- Nguyễn Văn An, Checking
('WDL', 'DTNBC220000002', NULL, 1000000, 'Debit', '2022-11-01 13:00:00', '2022-11-01 13:00:00'); -- Lê Ngọc Bích, Checking

-- 2022-12-01 (3 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('WDL', 'DTNBC220000001', NULL, 1500000, 'Debit', '2022-12-01 14:00:00', '2022-12-01 14:00:00'), -- Nguyễn Văn An, Checking
('INT', 'DTNBS220000001', NULL, 100000, 'Credit', '2022-12-01 08:00:00', '2022-12-01 08:00:00'), -- Nguyễn Văn An, Savings
('INT', 'DTNBS030000001', NULL, 120000, 'Credit', '2022-12-01 08:00:00', '2022-12-01 08:00:00'); -- Lê Ngọc Bích, Savings

-- 2023-01-01 (4 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('TRF', 'DTNBC220000001', 'DTNBS220000001', 100000, 'Debit', '2023-01-01 15:00:00', '2023-01-01 15:00:00'), -- Nguyễn Văn An, Checking → Savings
('POS', 'DTNBC130000001', NULL, 1300000, 'Debit', '2023-01-01 09:00:00', '2023-01-01 09:00:00'), -- Lê Văn Cường, Checking
('DEP', 'DTNBS030000001', NULL, 5000000, 'Credit', '2023-01-01 09:00:00', '2023-01-01 09:00:00'), -- Lê Ngọc Bích, Savings
('DEP', 'DTNBS030000002', NULL, 6000000, 'Credit', '2023-01-01 09:00:00', '2023-01-01 09:00:00'); -- Hoàng Thị Thanh Nhàn, Savings


-- 2023-02-01 (4 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('TRF', 'DTNBC220000001', 'DTNBC240000002', 15000000, 'Debit', '2023-02-01 16:00:00', '2023-02-01 16:00:00'), -- Nguyễn Văn An, Checking → Phạm Vân Thư (before lock)
('POS', 'DTNBC130000001', NULL, 1400000, 'Debit', '2023-02-01 10:00:00', '2023-02-01 10:00:00'), -- Lê Văn Cường, Checking
('DEP', 'DTNBS030000001', NULL, 6000000, 'Credit', '2023-02-01 10:00:00', '2023-02-01 10:00:00'), -- Lê Ngọc Bích, Savings
('DEP', 'DTNBS030000002', NULL, 5000000, 'Credit', '2023-02-01 10:00:00', '2023-02-01 10:00:00'); -- Hoàng Thị Thanh Nhàn, Savings

-- 2023-03-01 (4 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('PMT', 'DTNBC220000001', NULL, 1000000, 'Debit', '2023-03-01 09:00:00', '2023-03-01 09:00:00'), -- Nguyễn Văn An, Checking
('POS', 'DTNBC130000001', NULL, 1500000, 'Debit', '2023-03-01 11:00:00', '2023-03-01 11:00:00'), -- Lê Văn Cường, Checking
('DEP', 'DTNBS030000001', NULL, 6000000, 'Credit', '2023-03-01 11:00:00', '2023-03-01 11:00:00'), -- Lê Ngọc Bích, Savings
('DEP', 'DTNBS030000002', NULL, 7000000, 'Credit', '2023-03-01 11:00:00', '2023-03-01 11:00:00'); -- Hoàng Thị Thanh Nhàn, Savings

-- 2023-04-01 (4 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('REF', 'DTNBC220000001', NULL, 1500000, 'Credit', '2023-04-01 10:00:00', '2023-04-01 10:00:00'), -- Nguyễn Văn An, Checking
('POS', 'DTNBC130000001', NULL, 1600000, 'Debit', '2023-04-01 12:00:00', '2023-04-01 12:00:00'), -- Lê Văn Cường, Checking
('WDL', 'DTNBS030000001', NULL, 1000000, 'Debit', '2023-04-01 12:00:00', '2023-04-01 12:00:00'), -- Lê Ngọc Bích, Savings
('DEP', 'DTNBS030000002', NULL, 4000000, 'Credit', '2023-04-01 12:00:00', '2023-04-01 12:00:00'); -- Hoàng Thị Thanh Nhàn, Savings

-- 2023-05-01 (4 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('POS', 'DTNBC130000001', NULL, 1700000, 'Debit', '2023-05-01 13:00:00', '2023-05-01 13:00:00'), -- Lê Văn Cường, Checking
('WDL', 'DTNBS030000001', NULL, 1100000, 'Debit', '2023-05-01 13:00:00', '2023-05-01 13:00:00'), -- Lê Ngọc Bích, Savings
('WDL', 'DTNBS030000002', NULL, 1100000, 'Debit', '2023-05-01 13:00:00', '2023-05-01 13:00:00'), -- Hoàng Thị Thanh Nhàn, Savings
('DEP', 'DTNBF230000001', NULL, 10000000, 'Credit', '2023-05-01 09:00:00', '2023-05-01 09:00:00'); -- Nguyễn Văn An, Fixed

-- 2023-06-01 (6 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('INT', 'DTNBS220000001', NULL, 120000, 'Credit', '2023-06-01 08:00:00', '2023-06-01 08:00:00'), -- Nguyễn Văn An, Savings
('POS', 'DTNBC130000001', NULL, 1800000, 'Debit', '2023-06-01 14:00:00', '2023-06-01 14:00:00'), -- Lê Văn Cường, Checking
('INT', 'DTNBS030000001', NULL, 120000, 'Credit', '2023-06-01 08:00:00', '2023-06-01 08:00:00'), -- Lê Ngọc Bích, Savings
('INT', 'DTNBS030000002', NULL, 130000, 'Credit', '2023-06-01 08:00:00', '2023-06-01 08:00:00'), -- Hoàng Thị Thanh Nhàn, Savings
('POS', 'DTNBC240000001', NULL, 1400000, 'Debit', '2023-06-01 09:00:00', '2023-06-01 09:00:00'), -- Trần Thị Bích, Checking
('DEP', 'DTNBF230000002', NULL, 8000000, 'Credit', '2023-06-01 09:00:00', '2023-06-01 09:00:00'); -- Nguyễn Phương Đông, Fixed

-- 2023-07-01 (6 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('WDL', 'DTNBC130000001', NULL, 1000000, 'Debit', '2023-07-01 15:00:00', '2023-07-01 15:00:00'), -- Lê Văn Cường, Checking
('WDL', 'DTNBS030000002', NULL, 1000000, 'Debit', '2023-07-01 15:00:00', '2023-07-01 15:00:00'), -- Hoàng Thị Thanh Nhàn, Savings
('DEP', 'DTNBS230000001', NULL, 6000000, 'Credit', '2023-07-01 09:00:00', '2023-07-01 09:00:00'), -- Trần Thị Bích, Savings
('FEE', 'DTNBF230000002', NULL, 50000, 'Debit', '2023-07-01 09:00:00', '2023-07-01 09:00:00'), -- Nguyễn Phương Đông, Fixed
('DEP', 'DTNBF230000001', NULL, 8000000, 'Credit', '2023-07-01 09:00:00', '2023-07-01 09:00:00'), -- Nguyễn Văn An, Fixed
('WDL', 'DTNBS220000001', NULL, 1500000, 'Debit', '2023-07-01 12:00:00', '2023-07-01 12:00:00'); -- Nguyễn Văn An, Savings

-- 2023-08-01 (6 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('WDL', 'DTNBC130000001', NULL, 1100000, 'Debit', '2023-08-01 16:00:00', '2023-08-01 16:00:00'), -- Lê Văn Cường, Checking
('PMT', 'DTNBC220000001', NULL, 1000000, 'Debit', '2023-08-01 16:00:00', '2023-08-01 16:00:00'), -- Nguyễn Văn An, Checking
('REF', 'DTNBC220000002', NULL, 1500000, 'Credit', '2023-08-01 16:00:00', '2023-08-01 16:00:00'), -- Lê Ngọc Bích, Checking
('WDL', 'DTNBS030000002', NULL, 1100000, 'Debit', '2023-08-01 16:00:00', '2023-08-01 16:00:00'), -- Hoàng Thị Thanh Nhàn, Savings
('DEP', 'DTNBS230000001', NULL, 4000000, 'Credit', '2023-08-01 10:00:00', '2023-08-01 10:00:00'), -- Trần Thị Bích, Savings
('FEE', 'DTNBF230000002', NULL, 60000, 'Debit', '2023-08-01 10:00:00', '2023-08-01 10:00:00'); -- Nguyễn Phương Đông, Fixed

-- 2023-09-01 (5 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('INT', 'DTNBF230000001', NULL, 200000, 'Credit', '2023-09-01 08:00:00', '2023-09-01 08:00:00'), -- Nguyễn Văn An, Fixed
('WDL', 'DTNBC130000001', NULL, 1200000, 'Debit', '2023-09-01 09:00:00', '2023-09-01 09:00:00'), -- Lê Văn Cường, Checking
('WDL', 'DTNBS030000001', NULL, 1000000, 'Debit', '2023-09-01 11:00:00', '2023-09-01 11:00:00'), -- Lê Ngọc Bích, Savings
('WDL', 'DTNBS030000002', NULL, 1200000, 'Debit', '2023-09-01 09:00:00', '2023-09-01 09:00:00'), -- Hoàng Thị Thanh Nhàn, Savings
('DEP', 'DTNBS230000001', NULL, 5000000, 'Credit', '2023-09-01 11:00:00', '2023-09-01 11:00:00'); -- Trần Thị Bích, Savings

-- 2023-10-01 (3 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('FEE', 'DTNBF230000002', NULL, 50000, 'Debit', '2023-10-01 11:00:00', '2023-10-01 11:00:00'), -- Nguyễn Phương Đông, Fixed
('WDL', 'DTNBC130000001', NULL, 10000000, 'Debit', '2023-10-01 10:00:00', '2023-10-01 10:00:00'), -- Lê Văn Cường, Checking, Overdraft
('WDL', 'DTNBS030000002', NULL, 1300000, 'Debit', '2023-10-01 10:00:00', '2023-10-01 10:00:00'); -- Hoàng Thị Thanh Nhàn, Savings

-- 2023-11-01 (2 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('TRF', 'DTNBC130000001', 'DTNBC130000001', 1000000, 'Debit', '2023-11-01 11:00:00', '2023-11-01 11:00:00'), -- Lê Văn Cường, Checking, Self-transfer
('DEP', 'DTNBF230000002', NULL, 6000000, 'Credit', '2023-11-01 13:00:00', '2023-11-01 13:00:00'); -- Nguyễn Phương Đông, Fixed

-- 2023-12-01 (5 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('TRF', 'DTNBC130000001', 'INVALID123', 1200000, 'Debit', '2023-12-01 12:00:00', '2023-12-01 12:00:00'), -- Lê Văn Cường, Checking, Invalid account
('INT', 'DTNBS230000001', NULL, 110000, 'Credit', '2023-12-01 08:00:00', '2023-12-01 08:00:00'), -- Trần Thị Bích, Savings
('INT', 'DTNBS220000002', NULL, 140000, 'Credit', '2023-12-01 08:00:00', '2023-12-01 08:00:00'), -- Phạm Vân Thư, Savings
('INT', 'DTNBF230000001', NULL, 210000, 'Credit', '2023-12-01 08:00:00', '2023-12-01 08:00:00'), -- Nguyễn Văn An, Fixed
('DEP', 'DTNBF230000002', NULL, 5000000, 'Credit', '2023-12-01 14:00:00', '2023-12-01 14:00:00'); -- Nguyễn Phương Đông, Fixed

-- 2024-01-01 (3 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('TRF', 'DTNBC130000001', 'DTNBS220000001', 1500000, 'Debit', '2024-01-01 13:00:00', '2024-01-01 13:00:00'), -- Lê Văn Cường, Checking
('TRF', 'DTNBS030000002', 'DTNBC220000001', 20000000, 'Debit', '2024-01-01 13:00:00', '2024-01-01 13:00:00'), -- Hoàng Thị Thanh Nhàn, Savings, Overdraft
('DEP', 'DTNBF230000001', NULL, 4000000, 'Credit', '2024-01-01 15:00:00', '2024-01-01 15:00:00'); -- Nguyễn Văn An, Fixed

-- 2024-02-01 (2 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('TRF', 'DTNBC130000001', 'DTNBS230000001', 1400000, 'Debit', '2024-02-01 14:00:00', '2024-02-01 14:00:00'), -- Lê Văn Cường, Checking
('FEE', 'DTNBS030000002', NULL, 1000000, 'Debit', '2024-02-01 14:00:00', '2024-02-01 14:00:00'); -- Hoàng Thị Thanh Nhàn, Savings

-- 2024-03-01 (3 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('PMT', 'DTNBC130000001', NULL, 1000000, 'Debit', '2024-03-01 15:00:00', '2024-03-01 15:00:00'), -- Lê Văn Cường, Checking
('WDL', 'DTNBS030000002', NULL, 1100000, 'Debit', '2024-03-01 15:00:00', '2024-03-01 15:00:00'), -- Hoàng Thị Thanh Nhàn, Savings (Changed from PMT)
('INT', 'DTNBF230000001', NULL, 220000, 'Credit', '2024-03-01 08:00:00', '2024-03-01 08:00:00'); -- Nguyễn Văn An, Fixed

-- 2024-04-01 (2 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('PMT', 'DTNBC130000001', NULL, 1100000, 'Debit', '2024-04-01 16:00:00', '2024-04-01 16:00:00'), -- Lê Văn Cường, Checking
('WDL', 'DTNBS030000002', NULL, 1200000, 'Debit', '2024-04-01 16:00:00', '2024-04-01 16:00:00'); -- Hoàng Thị Thanh Nhàn, Savings (Changed from ACH)
select * from fixed_deposit_accounts;
-- 2024-05-01 (2 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('ACH', 'DTNBC130000001', NULL, 1200000, 'Debit', '2024-05-01 09:00:00', '2024-05-01 09:00:00'), -- Lê Văn Cường, Checking
('FEE', 'DTNBF230000001', NULL, 50000, 'Debit', '2024-05-01 13:00:00', '2024-05-01 13:00:00'); -- Nguyễn Văn An, Fixed, Penalty for early withdrawal
-- 2024-06-01 (5 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('ACH', 'DTNBC130000001', NULL, 1300000, 'Debit', '2024-06-01 10:00:00', '2024-06-01 10:00:00'), -- Lê Văn Cường, Checking
('INT', 'DTNBS230000001', NULL, 130000, 'Credit', '2024-06-01 08:00:00', '2024-06-01 08:00:00'), -- Trần Thị Bích, Savings
('INT', 'DTNBS220000002', NULL, 150000, 'Credit', '2024-06-01 08:00:00', '2024-06-01 08:00:00'), -- Phạm Vân Thư, Savings
('INT', 'DTNBS030000002', NULL, 150000, 'Credit', '2024-06-01 08:00:00', '2024-06-01 08:00:00'), -- Hoàng Thị Thanh Nhàn, Savings
('WDL', 'DTNBF230000001', 'DTNBS230000001', 30000000, 'Debit', '2024-06-01 14:00:00', '2024-06-01 14:00:00'); -- Nguyễn Văn An, Fixed (Changed from TRF)

-- 2024-07-01 (2 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('CHK', 'DTNBC130000001', NULL, 2000000, 'Debit', '2024-07-01 11:00:00', '2024-07-01 11:00:00'), -- Lê Văn Cường, Checking
('POS', 'DTNBC240000001', NULL, 1400000, 'Debit', '2024-07-01 09:00:00', '2024-07-01 09:00:00'); -- Trần Thị Bích, Checking

-- 2024-08-01 (2 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('REF', 'DTNBC130000001', NULL, 1500000, 'Credit', '2024-08-01 12:00:00', '2024-08-01 12:00:00'), -- Lê Văn Cường, Checking
('POS', 'DTNBC240000001', NULL, 1600000, 'Debit', '2024-08-01 10:00:00', '2024-08-01 10:00:00'); -- Trần Thị Bích, Checking

-- 2024-09-01 (2 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('WDL', 'DTNBS230000001', NULL, 1000000, 'Debit', '2024-09-01 14:00:00', '2024-09-01 14:00:00'), -- Trần Thị Bích, Savings (Changed from PMT)
('POS', 'DTNBC240000001', NULL, 1800000, 'Debit', '2024-09-01 11:00:00', '2024-09-01 11:00:00'); -- Trần Thị Bích, Checking

-- 2024-10-01 (1 transaction)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('POS', 'DTNBC240000001', NULL, 1000000, 'Debit', '2024-10-01 12:00:00', '2024-10-01 12:00:00'); -- Trần Thị Bích, Checking

-- 2024-11-01 (1 transaction)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('POS', 'DTNBC240000001', NULL, 10000000, 'Debit', '2024-11-01 13:00:00', '2024-11-01 13:00:00'); -- Trần Thị Bích, Checking

-- 2024-12-01 (2 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('WDL', 'DTNBC240000001', NULL, 1100000, 'Debit', '2024-12-01 14:00:00', '2024-12-01 14:00:00'), -- Trần Thị Bích, Checking
('INT', 'DTNBS030000002', NULL, 160000, 'Credit', '2024-12-01 08:00:00', '2024-12-01 08:00:00'); -- Hoàng Thị Thanh Nhàn, Savings

-- 2025-05-14 (10 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('DEP', 'DTNBS250000001', NULL, 5000000, 'Credit', '2025-05-14 14:00:00', '2025-05-14 14:00:00'), -- Nguyễn Thị Thu Trang, Savings
('DEP', 'DTNBF250000001', NULL, 9000000, 'Credit', '2025-05-14 14:00:00', '2025-05-14 14:00:00'), -- Nguyễn Thị Thu Trang, Fixed
('DEP', 'DTNBS250000001', NULL, 6000000, 'Credit', '2025-05-14 14:01:00', '2025-05-14 14:01:00'), -- Nguyễn Thị Thu Trang, Savings
('DEP', 'DTNBF250000001', NULL, 8000000, 'Credit', '2025-05-14 14:01:00', '2025-05-14 14:01:00'), -- Nguyễn Thị Thu Trang, Fixed
('DEP', 'DTNBS250000001', NULL, 7000000, 'Credit', '2025-05-14 14:02:00', '2025-05-14 14:02:00'), -- Nguyễn Thị Thu Trang, Savings
('DEP', 'DTNBF250000001', NULL, 7000000, 'Credit', '2025-05-14 14:02:00', '2025-05-14 14:02:00'), -- Nguyễn Thị Thu Trang, Fixed
('DEP', 'DTNBS250000001', NULL, 4000000, 'Credit', '2025-05-14 14:03:00', '2025-05-14 14:03:00'), -- Nguyễn Thị Thu Trang, Savings
('DEP', 'DTNBF250000001', NULL, 6000000, 'Credit', '2025-05-14 14:03:00', '2025-05-14 14:03:00'), -- Nguyễn Thị Thu Trang, Fixed
('DEP', 'DTNBS250000001', NULL, 8000000, 'Credit', '2025-05-14 14:04:00', '2025-05-14 14:04:00'), -- Nguyễn Thị Thu Trang, Savings
('FEE', 'DTNBF250000001', NULL, 50000, 'Debit', '2025-05-14 14:04:00', '2025-05-14 14:04:00'); -- Nguyễn Thị Thu Trang, Fixed

-- 2025-05-15 (2 transactions)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('WDL', 'DTNBS250000001', NULL, 1000000, 'Debit', '2025-05-15 14:00:00', '2025-05-15 14:00:00'); -- Nguyễn Thị Thu Trang, Savings

-- 2025-05-16 (1 transaction)
INSERT INTO TRANSACTIONS (trans_type_id, cus_account_id, related_cus_account_id, trans_amount, direction, trans_time, last_updated) VALUES
('WDL', 'DTNBS250000001', NULL, 1100000, 'Debit', '2025-05-16 15:00:00', '2025-05-16 15:00:00'); -- Nguyễn Thị Thu Trang, Savings


