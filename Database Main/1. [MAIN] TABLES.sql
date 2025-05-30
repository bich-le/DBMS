drop database main; 
create database main;
use main;


					-- BANK INFORMATION -------------------------------------------
CREATE TABLE IF NOT EXISTS BRANCHES (
    branch_id VARCHAR(4) PRIMARY KEY, -- VD: HN, HCM
    branch_name VARCHAR(100),
    branch_address VARCHAR(255)
);




					-- CUSTOMER SYSTEM -----------------------------------
                    
                    
CREATE TABLE IF NOT EXISTS CUSTOMERS (
    cus_id VARCHAR(18) PRIMARY KEY,
    cus_first_name VARCHAR(50),
    cus_last_name VARCHAR(50),
    cus_dob DATE,
    cus_email VARCHAR(50) UNIQUE,
    cus_address VARCHAR(100),
    cus_phone_num VARCHAR(15) UNIQUE,
    cus_sex ENUM('Male', 'Female'),
    cus_identification_id VARCHAR(20) UNIQUE,
    cus_join_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    branch_id VARCHAR(4),
    FOREIGN KEY (branch_id) REFERENCES BRANCHES(branch_id) ON DELETE SET NULL
);
CREATE TABLE CUSTOMERS_INDEX (
    branch_id VARCHAR(4),
    year CHAR(2),
    current_index INT,
    PRIMARY KEY (branch_id, year)
);
CREATE TABLE IF NOT EXISTS CUSTOMER_ACCOUNT_TYPES (
    cus_account_type_id VARCHAR(2) PRIMARY KEY,
    cus_account_type_name VARCHAR(30) NOT NULL UNIQUE -- Chưa pull vào git
);
CREATE TABLE IF NOT EXISTS CUSTOMER_ACCOUNTS (
    cus_account_id VARCHAR(17) primary key, -- DTNB[customer_account_type_id][2-digit year][7-digit index]
    cus_id VARCHAR(17),
    cus_account_status ENUM('Active', 'Temporarily Locked', 'Locked') DEFAULT 'Active', 
    opening_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    cus_account_type_id VARCHAR(2) ,
    
    FOREIGN KEY (cus_id) REFERENCES CUSTOMERS(cus_id) on delete cascade,
    FOREIGN KEY (cus_account_type_id) REFERENCES CUSTOMER_ACCOUNT_TYPES(cus_account_type_id) on delete set null
);
CREATE TABLE IF NOT EXISTS CUSTOMER_ACCOUNT_INDEX (
    cus_account_type_id VARCHAR(2),
    year CHAR(2),
    current_index INT DEFAULT 0,
    PRIMARY KEY (cus_account_type_id, year)
);
CREATE TABLE IF NOT EXISTS INTEREST_RATES (
    interest_rate_id TINYINT auto_increment PRIMARY KEY,
    interest_rate_val DECIMAL(5,3) NOT NULL 
		CHECK (interest_rate_val >0),
    cus_account_type_id VARCHAR(2) not null,
    min_balance INT(10) UNSIGNED,
    max_balance INT(10) UNSIGNED,
		CHECK (max_balance > min_balance) ,
    term INT(2),
    status ENUM('Active', 'Inactive') DEFAULT "Active",
	
    FOREIGN KEY (cus_account_type_id) REFERENCES CUSTOMER_ACCOUNT_TYPES(cus_account_type_id) on delete cascade
);
CREATE TABLE SAVING_ACCOUNTS(
    cus_account_id VARCHAR(17) primary key,
    interest_rate_id TINYint ,
    saving_acc_balance bigint unsigned not null,
    
    FOREIGN KEY (cus_account_id) REFERENCES CUSTOMER_ACCOUNTS(cus_account_id),
    FOREIGN KEY (interest_rate_id) REFERENCES INTEREST_RATES(interest_rate_id)
);
CREATE TABLE CHECK_ACCOUNTS(
    cus_account_id VARCHAR(17) primary key,
    check_acc_balance bigint not null,
    interest_rate_id TINYint,
    transfer_limit int unsigned default 100000000
		CHECK (transfer_limit <= 100000000) ,
	daily_transfer_limit BIGint unsigned,
        
    FOREIGN KEY (cus_account_id) REFERENCES CUSTOMER_ACCOUNTS(cus_account_id),
    FOREIGN KEY (interest_rate_id) REFERENCES INTEREST_RATES(interest_rate_id)
);
CREATE TABLE FIXED_DEPOSIT_ACCOUNTS(
    cus_account_id VARCHAR(17) PRIMARY KEY,
    interest_rate_id tinyint,
    deposit_amount bigint 
		CHECK (deposit_amount>1000),
    deposit_date DATE ,
    maturity_date DATE ,
		CHECK (maturity_date > deposit_date),
        
    FOREIGN KEY (cus_account_id) REFERENCES CUSTOMER_ACCOUNTS(cus_account_id) ON DELETE CASCADE,
    FOREIGN KEY (interest_rate_id) REFERENCES INTEREST_RATES(interest_rate_id) ON DELETE SET NULL
);



					-- TRANSACTIONS SYSTEM --------------------------------------------
CREATE TABLE TRANSACTION_TYPES(
    trans_type_id VARCHAR(3) PRIMARY KEY,
    trans_type_name VARCHAR(30) NOT NULL,
    description TEXT
);

CREATE TABLE TRANSACTION_ERROR_CODES (
    trans_error_code VARCHAR(10) PRIMARY KEY,
    trans_error_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    can_retry BOOLEAN DEFAULT FALSE,
    needs_human_review BOOLEAN DEFAULT FALSE
);


CREATE TABLE TRANSACTIONS (
    trans_id VARCHAR(18) PRIMARY KEY, --  DTNB[transactin_type_id][2-digit year][7-digit index][day]
    trans_type_id varchar(3),
    cus_account_id VARCHAR(17) ,
	related_cus_account_id VARCHAR(17) ,
    trans_amount INT NOT NULL
		CHECK (trans_amount >= 1000),
	direction ENUM('Debit', 'Credit') NOT NULL,
    trans_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    trans_status enum("Failed", "Successful") DEFAULT 'Successful',
	trans_error_code VARCHAR(10),
    
	FOREIGN KEY (trans_error_code) REFERENCES TRANSACTION_ERROR_CODES(trans_error_code) ON DELETE SET NULL,
	FOREIGN KEY (cus_account_id) REFERENCES CUSTOMER_ACCOUNTS(cus_account_id) ON DELETE SET NULL,
	FOREIGN KEY (trans_type_id) REFERENCES TRANSACTION_TYPES(trans_type_id) ON DELETE SET NULL
	)	;

 CREATE TABLE FAILED_TRANSACTIONS (
    trans_id VARCHAR(18) PRIMARY KEY,
    cus_account_id VARCHAR(17),
    trans_error_code VARCHAR(10) NOT NULL,
    trans_amount INT unsigned NOT NULL,
    failure_reason TEXT NOT NULL,
    attempted_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (trans_error_code) REFERENCES TRANSACTION_ERROR_CODES(trans_error_code) ON DELETE CASCADE,
	FOREIGN KEY (trans_id) REFERENCES TRANSACTIONS(trans_id) ON DELETE CASCADE, 
    FOREIGN KEY (cus_account_id) REFERENCES CUSTOMER_ACCOUNTS(cus_account_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS TRANSACTION_INDEX (
    trans_type_id VARCHAR(3),
    year_suffix CHAR(2),
    current_index INT DEFAULT 0,
    PRIMARY KEY (trans_type_id, year_suffix)
);
-- Bảng tạm lưu các bút toán Có cần xử lý
CREATE TABLE IF NOT EXISTS PENDING_CREDITS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    trans_type_id VARCHAR(3) NOT NULL,
    cus_account_id VARCHAR(17) NOT NULL,
    related_cus_account_id VARCHAR(17) NOT NULL,
    trans_amount INT NOT NULL CHECK (trans_amount >= 1000),
    trans_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_updated DATETIME ,
    
    INDEX (created_at) 
) ENGINE=InnoDB;

 -- INTERNAL SYSTEM --------------------------------------------
                    
                    

CREATE TABLE IF NOT EXISTS EMPLOYEE_POSITIONS( -- TẠO BẢNG EMPLOYEE_POSITIONS
	emp_position_id VARCHAR(2) primary KEY, -- 'T', 'M', etc
    emp_position_name VARCHAR(15),
    description TEXT
);
CREATE TABLE IF NOT EXISTS EMPLOYEES (
    emp_id VARCHAR(11) PRIMARY KEY, -- [branch_id][position_id][2-digit year][4-digit index]
    emp_fullname VARCHAR(100) NOT NULL,
    emp_sex ENUM('Male', 'Female') NOT NULL,
    emp_dob DATE NOT NULL,
    emp_phone_num VARCHAR(15) UNIQUE NOT NULL, -- + [Mã quốc gia][Số còn lại] VD: +84 901238881
    emp_email VARCHAR(50) UNIQUE NOT NULL,
    emp_address VARCHAR(255) NOT NULL,
    emp_salary INT(9) UNSIGNED,
    branch_id VARCHAR(4),
    emp_join_date DATETIME DEFAULT current_timestamp,
    emp_position_id VARCHAR(2),
    
    FOREIGN KEY (branch_id) REFERENCES BRANCHES(branch_id) ON DELETE CASCADE,
    FOREIGN KEY (emp_position_id) REFERENCES EMPLOYEE_POSITIONS(emp_position_id) ON DELETE SET NULL
);
CREATE TABLE IF NOT EXISTS EMPLOYEE_ACCOUNT_INDEX (
	emp_position_id VARCHAR(2),
    branch_id VARCHAR(4),
    year CHAR(2),
    current_index INT DEFAULT 0,
    PRIMARY KEY (emp_position_id, branch_id, year)
);
CREATE TABLE IF NOT EXISTS SERVICE_TYPES (
    service_type_id VARCHAR(50) PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    description TEXT
);
CREATE TABLE IF NOT EXISTS EMPLOYEE_CUSTOMERS (
    emp_id VARCHAR(11),
    cus_id VARCHAR(17),
    service_type_id VARCHAR(50) NOT NULL,
    assigned_date DATE NOT NULL,
    
    PRIMARY KEY (emp_id, cus_id),
    FOREIGN KEY (emp_id) REFERENCES EMPLOYEES(emp_id) ON DELETE CASCADE,
    FOREIGN KEY (cus_id) REFERENCES CUSTOMERS(cus_id) ON DELETE CASCADE,
    FOREIGN KEY (service_type_id) REFERENCES SERVICE_TYPES(service_type_id) ON DELETE RESTRICT
);
CREATE TABLE EMPLOYEE_ACCOUNTS (
    emp_id VARCHAR(11) PRIMARY KEY,                                      
    username VARCHAR(100) NOT NULL UNIQUE,                 
    password_hash VARCHAR(255) NOT NULL,                   -- Hashed password (never store plaintext passwords)
    status ENUM('Active', 'Inactive', 'Temporarily Suspended', 'Permanently Suspended') DEFAULT 'Active',
    suspension_time DATETIME NULL,
    reactivation_time DATETIME NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,         
    
    FOREIGN KEY (emp_id) REFERENCES EMPLOYEEs(emp_id) ON DELETE CASCADE  
);

							-- SYSTEM MANAGEMENT --------------------------------------------


CREATE TABLE FRAUD_PATTERNS (
    fraud_pattern_id INT auto_increment PRIMARY KEY,
    fraud_pattern_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);
CREATE TABLE SUSPICIONS (
    suspicion_id int auto_increment primary key,
    trans_id VARCHAR(18) ,
    fraud_pattern_id INT,
    detected_time DATETIME(6),
    severity_level enum('Low', 'Medium', 'High') ,
    suspicion_status ENUM('Unresolved', 'Investigating', 'Resolved', 'False_positive') DEFAULT 'Unresolved',
    
	FOREIGN KEY (trans_id) REFERENCES TRANSACTIONs(trans_id) ,
	FOREIGN KEY (fraud_pattern_id) REFERENCES FRAUD_PATTERNS(fraud_pattern_id) ON DELETE CASCADE
);
CREATE TABLE TEMP_SUSPICIONS (
    trans_id VARCHAR(18),
    fraud_pattern_id INT,
    detected_time DATETIME,
    severity_level ENUM('Low', 'Medium', 'High'),
    processed BOOLEAN DEFAULT FALSE,
    foreign key (trans_id) REFERENCES TRANSACTIONS(trans_id)
);
CREATE TABLE SUSPICIONS_PENDING_UPDATE (
    trans_id VARCHAR(18),
    fraud_pattern_id INT,
    detected_time DATETIME,
    severity_level ENUM('Low', 'Medium', 'High'),
    PRIMARY KEY (trans_id, fraud_pattern_id, detected_time)
);
				-- DEBUG & EVENT LOG ---
CREATE TABLE IF NOT EXISTS EVENT_LOG ( -- check events
    log_time DATETIME DEFAULT NOW(),
    message TEXT
);
CREATE TABLE IF NOT EXISTS DEBUG_LOG ( -- check bug procedure detect_amount_spike
    id INT AUTO_INCREMENT PRIMARY KEY,
    msg TEXT,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);                

					
