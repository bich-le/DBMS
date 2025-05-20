use main;
-- VIEWS AND STORED PROCEDURES FOR REPORTING 

--  1.  Lịch sử giao dịch hệ thống
--  Mục tiêu: Lấy lịch sử giao dịch trong một khoảng thời gian cho toàn bộ hệ thống.
--  Bảng liên quan: TRANSACTIONS, CUSTOMER_ACCOUNT, TRANSACTION_TYPE, BRANCH
--  View (cải tiến): vw_transaction_details (giữ nguyên)
DROP PROCEDURE IF EXISTS sp_all_transaction_history;
DROP VIEW IF EXISTS vw_transaction_details;

CREATE OR REPLACE VIEW vw_transaction_details AS
SELECT
    t.trans_id,
    t.trans_time,
    t.trans_amount,
    t.direction,
    ca.cus_account_id,
    ca.cus_id,
    tt.trans_type_name,
    b.branch_id,
    b.branch_name
FROM TRANSACTIONS t
JOIN CUSTOMER_ACCOUNTS ca ON t.cus_account_id = ca.cus_account_id
JOIN TRANSACTION_TYPES tt ON t.trans_type_id = tt.trans_type_id
JOIN CUSTOMERS c ON ca.cus_id = c.cus_id
JOIN BRANCHES b ON c.branch_id = b.branch_id;


DELIMITER $$

CREATE PROCEDURE sp_all_transaction_history (
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    -- Chi tiết giao dịch
    SELECT
        trans_id,
        trans_time,
        trans_amount,
        direction,
        cus_account_id,
        trans_type_name,
        branch_name
    FROM vw_transaction_details
    WHERE DATE(trans_time) BETWEEN start_date AND end_date
    ORDER BY trans_time DESC;

    -- Tổng hợp
    SELECT
        COUNT(*) AS total_transactions,
        SUM(trans_amount) AS total_amount,
        AVG(trans_amount) AS avg_transaction_amount
    FROM vw_transaction_details
    WHERE DATE(trans_time) BETWEEN start_date AND end_date;
END$$

DELIMITER ;


--  2.  Lịch sử giao dịch chi nhánh
--  Mục tiêu: Lấy lịch sử giao dịch cho một chi nhánh cụ thể.
--  Bảng liên quan: TRANSACTIONS, CUSTOMER_ACCOUNT, TRANSACTION_TYPE, BRANCH
--  Stored Procedure: sp_branch_transaction_report
DROP PROCEDURE IF EXISTS sp_branch_transaction_report;
DELIMITER $$

CREATE PROCEDURE sp_branch_transaction_report (
    IN p_branch_id VARCHAR(4),
    IN p_date_from DATE,
    IN p_date_to DATE
)
BEGIN
    -- Chi tiết
    SELECT
        trans_id,
        trans_time,
        trans_amount,
        direction,
        cus_account_id,
        trans_type_name
    FROM vw_transaction_details
    WHERE branch_id = p_branch_id
      AND DATE(trans_time) BETWEEN p_date_from AND p_date_to
    ORDER BY trans_time DESC;

    -- Tổng hợp
    SELECT
        COUNT(*) AS total_transactions,
        SUM(trans_amount) AS total_amount,
        AVG(trans_amount) AS avg_transaction_amount
    FROM vw_transaction_details
    WHERE branch_id = p_branch_id
      AND DATE(trans_time) BETWEEN p_date_from AND p_date_to;
END$$

DELIMITER ;

--  3.  Báo cáo suspicion
--  Mục tiêu: Lấy thông tin về các giao dịch bị nghi ngờ.
--  Bảng liên quan: SUSPICION, TRANSACTIONS, FRAUD_PATTERN
--  View (cải tiến): vw_suspicion_details (giữ nguyên)
DROP PROCEDURE IF EXISTS sp_suspicion_report;
DROP VIEW IF EXISTS vw_suspicion_details;


CREATE VIEW vw_suspicion_details AS
SELECT
    s.trans_id,
    s.detected_time,
    s.severity_level,
    s.suspicion_status,
    fp.fraud_pattern_name,
    t.trans_amount,
    t.trans_time,
    t.cus_account_id,
    c.cus_first_name,
    c.cus_last_name
FROM SUSPICIONS s
JOIN FRAUD_PATTERNS fp ON s.fraud_pattern_id = fp.fraud_pattern_id
JOIN TRANSACTIONS t ON s.trans_id = t.trans_id
JOIN CUSTOMER_ACCOUNTS ca ON t.cus_account_id = ca.cus_account_id
JOIN CUSTOMERS c ON ca.cus_id = c.cus_id;

DELIMITER $$

CREATE PROCEDURE sp_suspicion_report (
    IN p_status ENUM('Unresolved', 'Investigating', 'Resolved', 'False_positive'),
    IN p_from_date DATE,
    IN p_to_date DATE
)
BEGIN
    -- Chi tiết
    SELECT
        s.trans_id,
        s.detected_time,
        s.severity_level,
        s.suspicion_status,
        fp.fraud_pattern_name,
        t.trans_amount,
        t.trans_time,
        t.cus_account_id,
        c.cus_first_name,
        c.cus_last_name
    FROM SUSPICIONS s
    JOIN FRAUD_PATTERNS fp ON s.fraud_pattern_id = fp.fraud_pattern_id
    JOIN TRANSACTIONS t ON s.trans_id = t.trans_id
    JOIN CUSTOMER_ACCOUNTS ca ON t.cus_account_id = ca.cus_account_id
    JOIN CUSTOMERS c ON ca.cus_id = c.cus_id
    WHERE (p_status IS NULL OR s.suspicion_status = p_status)
      AND (p_from_date IS NULL OR s.detected_time >= p_from_date)
      AND (p_to_date IS NULL OR s.detected_time <= p_to_date)
    ORDER BY s.detected_time DESC;

    -- Tổng hợp
    SELECT
        suspicion_status,
        severity_level,
        COUNT(*) AS total_cases,
        SUM(t.trans_amount) AS total_amount_involved
    FROM SUSPICIONS s
    JOIN TRANSACTIONS t ON s.trans_id = t.trans_id
    WHERE (p_status IS NULL OR s.suspicion_status = p_status)
      AND (p_from_date IS NULL OR s.detected_time >= p_from_date)
      AND (p_to_date IS NULL OR s.detected_time <= p_to_date)
    GROUP BY suspicion_status, severity_level;
END$$

DELIMITER ;



--  4.  Báo cáo khách hàng theo chi nhánh
--  Mục tiêu: Lấy thông tin tổng hợp về khách hàng theo chi nhánh.
--  Bảng liên quan: CUSTOMERS, CUSTOMER_ACCOUNT, BRANCH

DROP PROCEDURE IF EXISTS sp_customer_summary_by_branch;
DROP VIEW IF EXISTS vw_customer_branch_details;


CREATE VIEW vw_customer_branch_details AS
SELECT
    c.cus_id AS customer_id,
    c.cus_first_name,
    c.cus_last_name,
    ca.cus_account_id AS customer_account_id,
    b.branch_id,
    b.branch_name
FROM CUSTOMERS c
JOIN CUSTOMER_ACCOUNTS ca ON c.cus_id = ca.cus_id
JOIN BRANCHES b ON c.branch_id = b.branch_id;


DELIMITER $$

CREATE PROCEDURE sp_customer_summary_by_branch (
    IN p_branch_id VARCHAR(4)
)
BEGIN
    -- Thống kê tổng
    SELECT
        branch_id,
        branch_name,
        COUNT(DISTINCT customer_id) AS total_customers,
        COUNT(customer_account_id) AS total_accounts
    FROM vw_customer_branch_details
    WHERE (p_branch_id IS NULL OR branch_id = p_branch_id)
    GROUP BY branch_id, branch_name;

    -- Liệt kê chi tiết khách hàng (tuỳ chọn)
    SELECT
        customer_id,
        cus_first_name,
        cus_last_name,
        customer_account_id,
        branch_name
    FROM vw_customer_branch_details
    WHERE (p_branch_id IS NULL OR branch_id = p_branch_id)
    ORDER BY branch_id, customer_id;
END$$

DELIMITER ;



--  5.  Báo cáo tổng hợp tài khoản
--  Mục tiêu: Lấy thông tin tổng hợp về tài khoản (số lượng, tổng số dư) theo chi nhánh và loại tài khoản.
--  Bảng liên quan: CUSTOMER_ACCOUNT, BRANCH, SAVING_ACCOUNT, CURRENT_ACCOUNT, FIXED_DEPOSIT_ACCOUNT
--  Stored Procedure: sp_account_summary_report
DROP PROCEDURE IF EXISTS sp_account_summary_report;
DROP VIEW IF EXISTS vw_account_summary_report;


CREATE VIEW vw_account_summary_report AS
SELECT
    b.branch_id,
    b.branch_name,
    ca.cus_account_id,
    ca.cus_account_type_id,
    CASE
        WHEN ca.cus_account_type_id = 'S' THEN 'Saving'
        WHEN ca.cus_account_type_id = 'C' THEN 'Checking'
        WHEN ca.cus_account_type_id = 'F' THEN 'Fixed'
        ELSE 'Other'
    END AS account_type,
    COALESCE(sa.saving_acc_balance, ch.check_acc_balance, fda.deposit_amount, 0) AS balance
FROM CUSTOMER_ACCOUNTS ca
JOIN CUSTOMERS c ON ca.cus_id = c.cus_id
JOIN BRANCHES b ON c.branch_id = b.branch_id
LEFT JOIN SAVING_ACCOUNTS sa ON ca.cus_account_id = sa.cus_account_id
LEFT JOIN CHECK_ACCOUNTS ch ON ca.cus_account_id = ch.cus_account_id
LEFT JOIN FIXED_DEPOSIT_ACCOUNTS fda ON ca.cus_account_id = fda.cus_account_id;


DELIMITER $$

CREATE PROCEDURE sp_account_summary_report (
    IN p_branch_id VARCHAR(50),
    IN p_account_type VARCHAR(10)  -- Giá trị: 'Saving', 'Checking', 'Fixed' hoặc NULL để lấy tất cả
)
BEGIN
    SELECT
        b.branch_name,
        ca.cus_account_type_id,
        CASE
            WHEN ca.cus_account_type_id = 'S' THEN 'Saving'
            WHEN ca.cus_account_type_id = 'C' THEN 'Checking'
            WHEN ca.cus_account_type_id = 'F' THEN 'Fixed'
            ELSE 'Other'
        END AS account_type,
        COUNT(*) AS total_accounts,
        SUM(
            CASE
                WHEN ca.cus_account_type_id = 'S' THEN sa.saving_acc_balance
                WHEN ca.cus_account_type_id = 'C' THEN ch.check_acc_balance
                WHEN ca.cus_account_type_id = 'F' THEN fda.deposit_amount
                ELSE 0
            END
        ) AS total_balance,
        AVG(
            CASE
                WHEN ca.cus_account_type_id = 'S' THEN sa.saving_acc_balance
                WHEN ca.cus_account_type_id = 'C' THEN ch.check_acc_balance
                WHEN ca.cus_account_type_id = 'F' THEN fda.deposit_amount
                ELSE NULL
            END
        ) AS avg_balance
    FROM CUSTOMER_ACCOUNTS ca
    JOIN CUSTOMERS c ON ca.cus_id = c.cus_id
    JOIN BRANCHES b ON c.branch_id = b.branch_id
    LEFT JOIN SAVING_ACCOUNTS sa ON ca.cus_account_id = sa.cus_account_id
    LEFT JOIN CHECK_ACCOUNTS ch ON ca.cus_account_id = ch.cus_account_id
    LEFT JOIN FIXED_DEPOSIT_ACCOUNTS fda ON ca.cus_account_id = fda.cus_account_id
    WHERE (p_branch_id IS NULL OR b.branch_id = p_branch_id)
      AND (p_account_type IS NULL OR
            (p_account_type = 'Saving' AND ca.cus_account_type_id = 'S') OR
            (p_account_type = 'Checking' AND ca.cus_account_type_id = 'C') OR
            (p_account_type = 'Fixed' AND ca.cus_account_type_id = 'F'))
    GROUP BY b.branch_name, ca.cus_account_type_id;
END$$

DELIMITER ;
