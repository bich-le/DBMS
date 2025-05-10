
-- ==========================
-- CUSTOMERS TRIGGERS
-- ==========================
-- ensure that Customer account must belong to at least one account type
DELIMITER //
CREATE TRIGGER check_account_type_after_insert
AFTER INSERT ON CUSTOMER_ACCOUNT
FOR EACH ROW
BEGIN
    DECLARE cnt INT;

    SELECT COUNT(*) INTO cnt
    FROM (
        SELECT customer_account_id FROM SAVING_ACCOUNT WHERE customer_account_id = NEW.customer_account_id
        UNION
        SELECT customer_account_id FROM CURRENT_ACCOUNT WHERE customer_account_id = NEW.customer_account_id
        UNION
        SELECT customer_account_id FROM FIXED_DEPOSIT_ACCOUNT WHERE customer_account_id = NEW.customer_account_id
    ) AS temp;

    IF cnt = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer account must belong to at least one account type (saving/current/fixed deposit)';
    END IF;
END;
//
DELIMITER ;


-- ==========================
-- CUSTOMERS PROCEDURES
-- ==========================

-- add new customer
DELIMITER //
CREATE PROCEDURE add_customer(
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_Address VARCHAR(100),
    IN p_PhoneNumber VARCHAR(15),
    IN p_Gender VARCHAR(10),
    IN p_identification_id VARCHAR(20)
)
BEGIN
    INSERT INTO Customers (
        FirstName, LastName, Address, PhoneNumber, Gender, identification_id
    ) VALUES (
        p_FirstName, p_LastName, p_Address, p_PhoneNumber, p_Gender, p_identification_id
    );
END;
//
DELIMITER ;

-- update customer information 
DELIMITER //
CREATE PROCEDURE update_customer_flexible(
    IN p_Customer_ID INT,
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_Address VARCHAR(100),
    IN p_PhoneNumber VARCHAR(15),
    IN p_Gender VARCHAR(10),
    IN p_identification_id VARCHAR(20)
)
BEGIN
    IF p_FirstName IS NOT NULL THEN
        UPDATE Customers SET FirstName = p_FirstName WHERE Customer_ID = p_Customer_ID;
    END IF;

    IF p_LastName IS NOT NULL THEN
        UPDATE Customers SET LastName = p_LastName WHERE Customer_ID = p_Customer_ID;
    END IF;

    IF p_Address IS NOT NULL THEN
        UPDATE Customers SET Address = p_Address WHERE Customer_ID = p_Customer_ID;
    END IF;

    IF p_PhoneNumber IS NOT NULL THEN
        UPDATE Customers SET PhoneNumber = p_PhoneNumber WHERE Customer_ID = p_Customer_ID;
    END IF;

    IF p_Gender IS NOT NULL THEN
        UPDATE Customers SET Gender = p_Gender WHERE Customer_ID = p_Customer_ID;
    END IF;

    IF p_identification_id IS NOT NULL THEN
        UPDATE Customers SET identification_id = p_identification_id WHERE Customer_ID = p_Customer_ID;
    END IF;
END;
//
DELIMITER ;
-- add saving account 
DELIMITER //
CREATE PROCEDURE add_saving_account(
    IN p_customer_id INT,
    IN p_rate_id INT,
    IN p_saving_balance INT
)
BEGIN
    DECLARE new_acc_id INT;
    DECLARE customer_exists INT;

    -- Check if the customer exists
    SELECT COUNT(*) INTO customer_exists
    FROM Customers
    WHERE customer_id = p_customer_id;

    IF customer_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer ID does not exist';
    ELSE
        -- Create a new record in CUSTOMER_ACCOUNT
        INSERT INTO CUSTOMER_ACCOUNT(customer_id)
        VALUES (p_customer_id);

        SET new_acc_id = LAST_INSERT_ID();

        -- Add a saving account linked to the customer account
        INSERT INTO SAVING_ACCOUNT(customer_account_id, rate_id, saving_acc_balance)
        VALUES (new_acc_id, p_rate_id, p_saving_balance);
    END IF;
END;
//
DELIMITER ;
-- add current account
DELIMITER //
CREATE PROCEDURE add_current_account(
    IN p_customer_id INT,
    IN p_current_balance INT,
    IN p_daily_limit DECIMAL(10,2)
)
BEGIN
    DECLARE new_acc_id INT;
    DECLARE customer_exists INT;

    -- Check if the customer exists
    SELECT COUNT(*) INTO customer_exists
    FROM Customers
    WHERE customer_id = p_customer_id;

    IF customer_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer ID does not exist';
    ELSE
        -- Create a new record in CUSTOMER_ACCOUNT
        INSERT INTO CUSTOMER_ACCOUNT(customer_id)
        VALUES (p_customer_id);

        SET new_acc_id = LAST_INSERT_ID();

        -- Add a current account linked to the customer account
        INSERT INTO CURRENT_ACCOUNT(customer_account_id, current_acc_balance, daily_transfer_limit)
        VALUES (new_acc_id, p_current_balance, p_daily_limit);
    END IF;
END;
//
DELIMITER ;
-- add fixed deposit account 
DELIMITER //
CREATE PROCEDURE add_fixed_account(
    IN p_customer_id INT,
    IN p_amount DECIMAL(12,2),
    IN p_deposit_date DATE,
    IN p_maturity_date DATE,
    IN p_rate_id INT
)
BEGIN
    DECLARE new_acc_id INT;
    DECLARE customer_exists INT;

    -- Check if the customer exists
    SELECT COUNT(*) INTO customer_exists
    FROM Customers
    WHERE customer_id = p_customer_id;

    IF customer_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer ID does not exist';
    ELSE
        -- Create a new record in CUSTOMER_ACCOUNT
        INSERT INTO CUSTOMER_ACCOUNT(customer_id)
        VALUES (p_customer_id);

        SET new_acc_id = LAST_INSERT_ID();

        -- Add a fixed deposit account linked to the customer account
        INSERT INTO FIXED_DEPOSIT_ACCOUNT(
            customer_account_id,
            deposit_amount,
            deposit_date,
            maturity_date,
            rate_id
        )
        VALUES (
            new_acc_id,
            p_amount,
            p_deposit_date,
            p_maturity_date,
            p_rate_id
        );
    END IF;
END;
//
DELIMITER ;
-- update saving account interest:
CREATE EVENT update_saving_account_interest
ON SCHEDULE EVERY 1 MONTH
DO
BEGIN
    UPDATE SAVING_ACCOUNT sa
    JOIN INTEREST_RATE ir ON sa.interest_rate_id = ir.interest_rate_id
    SET sa.saving_acc_balance = sa.saving_acc_balance + (sa.saving_acc_balance * ir.interest_rate_val)
    WHERE ir.status = 'Active';
END;
