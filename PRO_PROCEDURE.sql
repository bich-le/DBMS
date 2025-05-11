-- (ĐÔNG) VIEWS AND STORED PROCEDURES FOR REPORTING 

--  1.  Lịch sử giao dịch hệ thống
--  Mục tiêu: Lấy lịch sử giao dịch trong một khoảng thời gian cho toàn bộ hệ thống.
--  Bảng liên quan: TRANSACTIONS, CUSTOMER_ACCOUNT, TRANSACTION_TYPE, BRANCH
--  View (cải tiến): vw_transaction_details (giữ nguyên)

CREATE OR REPLACE VIEW vw_transaction_details AS
SELECT
    t.transaction_id,
    t.transaction_time,
    t.transaction_amount,
    t.direction,
    ca.customer_account_id,
    ca.customer_id,
    tt.transaction_type_name,
    b.branch_id,
    b.branch_name
FROM TRANSACTIONS t
JOIN CUSTOMER_ACCOUNT ca ON t.customer_account_id = ca.customer_account_id
JOIN TRANSACTION_TYPE tt ON t.transaction_type_id = tt.transaction_type_id
JOIN BRANCH b ON SUBSTRING_INDEX(ca.customer_account_id, '-', 1) = b.branch_id;

--  Stored Procedure: sp_all_transaction_history

CREATE PROCEDURE sp_all_transaction_history (
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    SELECT
        transaction_id,
        transaction_time,
        transaction_amount,
        direction,
        customer_account_id,
        transaction_type_name,
        branch_name
    FROM vw_transaction_details
    WHERE transaction_time BETWEEN start_date AND end_date
    ORDER BY transaction_time DESC;
END;

--  2.  Lịch sử giao dịch chi nhánh
--  Mục tiêu: Lấy lịch sử giao dịch cho một chi nhánh cụ thể.
--  Bảng liên quan: TRANSACTIONS, CUSTOMER_ACCOUNT, TRANSACTION_TYPE, BRANCH
--  Stored Procedure: sp_branch_transaction_report

CREATE PROCEDURE sp_branch_transaction_report (
    IN branch_id VARCHAR(4)
)
BEGIN
    SELECT
        transaction_id,
        transaction_time,
        transaction_amount,
        direction,
        customer_account_id,
        transaction_type_name
    FROM vw_transaction_details
    WHERE branch_id = branch_id
    ORDER BY transaction_time DESC;
END;

--  3.  Lịch sử giao dịch của nhân viên
--  Mục tiêu: Lấy lịch sử giao dịch được thực hiện bởi một nhân viên cụ thể.
--  Bảng liên quan: TRANSACTIONS, CUSTOMER_ACCOUNT, EMPLOYEES
--  LƯU Ý QUAN TRỌNG:  KHÔNG THỂ thực hiện chính xác nếu không có thông tin về nhân viên thực hiện giao dịch trong bảng TRANSACTIONS.
--  Giải pháp thay thế (KHÔNG chính xác hoàn toàn): Lấy giao dịch liên quan đến khách hàng mà nhân viên đó phục vụ (EMPLOYEE_CUSTOMER).

DELIMITER //
CREATE PROCEDURE sp_employee_transaction_report (
    IN p_employee_id VARCHAR(11),  -- Thêm tiền tố 'p_' để phân biệt với tên cột
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT
        t.transaction_id,
        t.transaction_time,
        t.transaction_amount,
        t.direction,
        t.customer_account_id,
        tt.transaction_type_name,
        e.emp_fullname AS employee_name  -- Thêm tên nhân viên vào kết quả
    FROM TRANSACTIONS t
    JOIN CUSTOMER_ACCOUNT ca ON t.customer_account_id = ca.customer_account_id
    JOIN TRANSACTION_TYPE tt ON t.transaction_type_id = tt.transaction_type_id
    JOIN EMPLOYEE_CUSTOMER ec ON ca.customer_id = ec.customer_id
    JOIN EMPLOYEES e ON ec.emp_id = e.emp_id  -- JOIN thêm bảng EMPLOYEES để lấy tên
    WHERE ec.emp_id = p_employee_id  -- Sửa thành so sánh emp_id với tham số đầu vào
      AND (p_start_date IS NULL OR t.transaction_time >= p_start_date)
      AND (p_end_date IS NULL OR t.transaction_time <= p_end_date)
    ORDER BY t.transaction_time DESC;
END //
DELIMITER ;

--  4.  Báo cáo suspicion
--  Mục tiêu: Lấy thông tin về các giao dịch bị nghi ngờ.
--  Bảng liên quan: SUSPICION, TRANSACTIONS, FRAUD_PATTERN
--  View (cải tiến): vw_suspicion_details (giữ nguyên)

CREATE OR REPLACE VIEW vw_suspicion_details AS
SELECT
    s.transaction_id,
    s.detected_time,
    s.severity_level,
    s.suspicion_status,
    fp.fraud_pattern_name,
    t.transaction_amount,
    t.transaction_time,
    t.customer_account_id
FROM SUSPICION s
JOIN FRAUD_PATTERN fp ON s.fraud_pattern_id = fp.fraud_pattern_id
JOIN TRANSACTIONS t ON s.transaction_id = t.transaction_id;

--  Stored Procedure: sp_suspicion_report
-- 4. Báo cáo suspicion (ĐÃ SỬA)
DELIMITER //
CREATE PROCEDURE sp_suspicion_report (
    IN p_status ENUM('Unresolved', 'Investigating', 'Resolved', 'False_positive'),
    IN p_from_date DATE,
    IN p_to_date DATE
)
BEGIN
    SELECT
        s.transaction_id,
        s.detected_time,
        s.severity_level,
        s.suspicion_status,
        fp.fraud_pattern_name,
        t.transaction_amount,
        t.transaction_time,
        t.customer_account_id,
        c.cus_first_name,
        c.cus_last_name
    FROM SUSPICION s
    JOIN FRAUD_PATTERN fp ON s.fraud_pattern_id = fp.fraud_pattern_id
    JOIN TRANSACTIONS t ON s.transaction_id = t.transaction_id
    JOIN CUSTOMER_ACCOUNT ca ON t.customer_account_id = ca.customer_account_id
    JOIN CUSTOMERS c ON ca.customer_id = c.customer_id
    WHERE (p_status IS NULL OR s.suspicion_status = p_status)
      AND (p_from_date IS NULL OR s.detected_time >= p_from_date)
      AND (p_to_date IS NULL OR s.detected_time <= p_to_date)
    ORDER BY s.detected_time DESC;
END //
DELIMITER ;

--  5.  Lịch sử system activity
--  Mục tiêu: Lấy lịch sử hoạt động của hệ thống.
--  Bảng liên quan: SYSTEM_ACTIVITIES_HISTORY, EMPLOYEES, BRANCH, DEVICE, SYSTEM_ACTIVITY_CATEGORIES
--  View (cải tiến): vw_system_activity_details (giữ nguyên)

CREATE OR REPLACE VIEW vw_system_activity_details AS
SELECT
    sah.activity_id,
    sah.activity_time,
    sah.description,
    sah.sys_activity_status,
    e.emp_fullname,
    b.branch_name,
    d.device_name,
    sac.activity_category_name,
    sah.old_value,
    sah.new_value,
    sah.objective_id
FROM SYSTEM_ACTIVITIES_HISTORY sah
LEFT JOIN EMPLOYEES e ON sah.emp_id = e.emp_id
LEFT JOIN BRANCH b ON e.branch_id = b.branch_id
LEFT JOIN DEVICE d ON sah.device_id = d.device_id
LEFT JOIN SYSTEM_ACTIVITY_CATEGORIES sac ON sah.activity_category_id = sac.activity_category_id;

--  Stored Procedure: sp_system_activity_log
DELIMITER //
CREATE PROCEDURE sp_system_activity_log (
    IN p_branch_id VARCHAR(4),
    IN p_employee_id VARCHAR(11),
    IN p_activity_category VARCHAR(30),
    IN p_from_date DATETIME,
    IN p_to_date DATETIME
)
BEGIN
    SELECT
        sah.activity_id,
        sah.activity_time,
        sah.description,
        sah.sys_activity_status,
        e.emp_fullname,
        b.branch_name,
        d.device_name,
        sac.activity_category_name
    FROM SYSTEM_ACTIVITIES_HISTORY sah
    LEFT JOIN EMPLOYEES e ON sah.emp_id = e.emp_id
    LEFT JOIN BRANCH b ON e.branch_id = b.branch_id
    LEFT JOIN DEVICE d ON sah.device_id = d.device_id
    LEFT JOIN SYSTEM_ACTIVITY_CATEGORIES sac ON sah.activity_category_id = sac.activity_category_id
    WHERE (p_branch_id IS NULL OR b.branch_id = p_branch_id)
      AND (p_employee_id IS NULL OR e.emp_id = p_employee_id)
      AND (p_activity_category IS NULL OR sac.activity_category_name = p_activity_category)
      AND (p_from_date IS NULL OR sah.activity_time >= p_from_date)
      AND (p_to_date IS NULL OR sah.activity_time <= p_to_date)
    ORDER BY sah.activity_time DESC;
END //
DELIMITER ;

--  6.  Lịch sử thay đổi lãi suất
--  Mục tiêu: Lấy lịch sử thay đổi của lãi suất.
--  Bảng liên quan: INTEREST_RATE
--  Stored Procedure: sp_interest_rate_changes

CREATE PROCEDURE sp_interest_rate_changes ()
BEGIN
    SELECT
        interest_rate_id,
        interest_rate_val,
        account_type_id,
        min_balance,
        max_balance,
        term,
        status
    FROM INTEREST_RATE
    ORDER BY interest_rate_id DESC;
END;

--  7.  Báo cáo khách hàng theo chi nhánh
--  Mục tiêu: Lấy thông tin tổng hợp về khách hàng theo chi nhánh.
--  Bảng liên quan: CUSTOMERS, CUSTOMER_ACCOUNT, BRANCH
--  View (cải tiến): vw_customer_branch_details (giữ nguyên)

CREATE OR REPLACE VIEW vw_customer_branch_details AS
SELECT
    c.customer_id,
    c.cus_first_name,
    c.cus_last_name,
    ca.customer_account_id,
    b.branch_id,
    b.branch_name
FROM CUSTOMERS c
JOIN CUSTOMER_ACCOUNT ca ON c.customer_id = ca.customer_id
JOIN BRANCH b ON SUBSTRING_INDEX(ca.customer_account_id, '-', 1) = b.branch_id;

--  Stored Procedure: sp_customer_summary_by_branch

CREATE PROCEDURE sp_customer_summary_by_branch (
    IN branch_id VARCHAR(4)
)
BEGIN
    SELECT
        branch_id,
        branch_name,
        COUNT(DISTINCT customer_id) AS total_customers,
        COUNT(customer_account_id) AS total_accounts
    FROM vw_customer_branch_details
    WHERE branch_id = branch_id
    GROUP BY branch_id, branch_name;
END;

--  8.  Báo cáo tổng hợp tài khoản
--  Mục tiêu: Lấy thông tin tổng hợp về tài khoản (số lượng, tổng số dư) theo chi nhánh và loại tài khoản.
--  Bảng liên quan: CUSTOMER_ACCOUNT, BRANCH, SAVING_ACCOUNT, CURRENT_ACCOUNT, FIXED_DEPOSIT_ACCOUNT
--  Stored Procedure: sp_account_summary_report

DELIMITER //
CREATE PROCEDURE sp_account_summary_report (
    IN p_branch_id VARCHAR(4),
    IN p_account_type ENUM('Saving', 'Current', 'Fixed')
)
BEGIN
    SELECT
        b.branch_name,
        ca.cus_account_type,
        COUNT(*) AS total_accounts,
        SUM(
            CASE
                WHEN ca.cus_account_type = 'Saving' THEN sa.saving_acc_balance
                WHEN ca.cus_account_type = 'Current' THEN cur.current_acc_balance
                WHEN ca.cus_account_type = 'Fixed' THEN fda.deposit_amount
                ELSE 0
            END
        ) AS total_balance
    FROM CUSTOMER_ACCOUNT ca
    JOIN BRANCH b ON SUBSTRING_INDEX(ca.customer_account_id, '-', 1) = b.branch_id
    LEFT JOIN SAVING_ACCOUNT sa ON ca.customer_account_id = sa.customer_account_id
    LEFT JOIN CURRENT_ACCOUNT cur ON ca.customer_account_id = cur.customer_account_id
    LEFT JOIN FIXED_DEPOSIT_ACCOUNT fda ON ca.customer_account_id = fda.customer_account_id
    WHERE (p_branch_id IS NULL OR b.branch_id = p_branch_id)
      AND (p_account_type IS NULL OR ca.cus_account_type = p_account_type)
    GROUP BY b.branch_name, ca.cus_account_type;
END //
DELIMITER ;