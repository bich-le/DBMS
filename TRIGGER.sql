
-- ==========================
-- CUSTOMERS PROCEDURES
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
