
-- P1 Create Customer 
-- Requirements: reject duplicate email, set Active, return customer ID and registration status.
-- DROP PROCEDURE IF EXISTS CreateCustomer;
DELIMITER $$
CREATE PROCEDURE CreateCustomer(
    IN p_customer_name VARCHAR(100),
    IN p_phone VARCHAR(15),
    IN p_email VARCHAR(100),
    IN p_city VARCHAR(50)
)
BEGIN
    DECLARE v_customer_id INT;
    IF p_customer_name IS NULL OR TRIM(p_customer_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer name is required';
    END IF;
    IF p_email IS NULL OR TRIM(p_email) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email is required';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM customers
        WHERE LOWER(email) = LOWER(TRIM(p_email))
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Duplicate email: customer already exists';
    END IF;
    INSERT INTO customers
        (customer_name, phone, email, city, status)
    VALUES
        (TRIM(p_customer_name), p_phone, LOWER(TRIM(p_email)),
         p_city, 'Active');
    SET v_customer_id = LAST_INSERT_ID();
    SELECT
        v_customer_id AS customer_id,
        'Customer registered successfully' AS registration_status;
END$$
DELIMITER ;
CALL CreateCustomer(
    'Neha Shah',
    '9876543210',
    'newneha@example.com',
    'Mumbai'
);

-- p2 Open Accounts

-- Requirements: validate active customer, allow Savings/Current, reject negative deposit, record opening deposit when
-- applicable.
-- DROP PROCEDURE IF EXISTS OpenAccount;
DELIMITER $$
CREATE PROCEDURE OpenAccount(
    IN p_customer_id INT,
    IN p_account_type VARCHAR(20),
    IN p_opening_deposit DECIMAL(15,2)
)
BEGIN
    DECLARE v_account_id INT;
    DECLARE v_customer_status VARCHAR(20);
    DECLARE v_account_type VARCHAR(20);
    DECLARE v_reference VARCHAR(100);
    IF p_opening_deposit IS NULL OR p_opening_deposit < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Opening deposit cannot be negative';
    END IF;
    SET v_account_type = CASE UPPER(TRIM(p_account_type))
        WHEN 'SAVINGS' THEN 'Savings'
        WHEN 'CURRENT' THEN 'Current'
        ELSE NULL
    END;
    IF v_account_type IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Account type must be Savings or Current';
    END IF;
    SELECT status
    INTO v_customer_status
    FROM customers
    WHERE customer_id = p_customer_id;
    IF v_customer_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer does not exist';
    END IF;
IF v_customer_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer is not active';
    END IF;
    START TRANSACTION;
    INSERT INTO accounts
        (customer_id, account_type, balance, opened_date, status)
    VALUES
        (p_customer_id, v_account_type, p_opening_deposit,
         CURDATE(), 'Active');
    SET v_account_id = LAST_INSERT_ID();
    IF p_opening_deposit > 0 THEN
        SET v_reference = CONCAT('OPEN-', UUID());
        INSERT INTO transactions
            (account_id, transaction_type, amount,
             transaction_date, reference_no)
        VALUES
            (v_account_id, 'Deposit', p_opening_deposit,
             CURRENT_TIMESTAMP, v_reference);
    END IF;
    COMMIT;
    SELECT
        v_account_id AS account_id,
        v_account_type AS account_type,
        p_opening_deposit AS opening_balance;
END$$
DELIMITER ;
CALL OpenAccount(101, 'Savings', 10000);



-- p3 Deposit money
-- Requirements: positive amount, active account, increase balance, insert Deposit transaction and reference.
-- DROP PROCEDURE IF EXISTS DepositMoney;
DELIMITER $$
CREATE PROCEDURE DepositMoney(
    IN p_account_id INT,
    IN p_amount DECIMAL(15,2)
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_new_balance DECIMAL(15,2);
    DECLARE v_transaction_id INT;
    DECLARE v_reference VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    IF p_amount IS NULL OR p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Deposit amount must be greater than zero';
    END IF;
    START TRANSACTION;
    SELECT status, balance
    INTO v_status, v_new_balance
    FROM accounts
    WHERE account_id = p_account_id
    FOR UPDATE;
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Account does not exist';
    END IF;
    IF v_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Account is not active';
    END IF;
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_account_id;
    SET v_new_balance = v_new_balance + p_amount;
    SET v_reference = CONCAT('DEP-', UUID());
    INSERT INTO transactions
        (account_id, transaction_type, amount,
         transaction_date, reference_no)
    VALUES
        (p_account_id, 'Deposit', p_amount,
         CURRENT_TIMESTAMP, v_reference);
    SET v_transaction_id = LAST_INSERT_ID();
    COMMIT;
     SELECT
        p_account_id AS account_id,
        v_new_balance AS new_balance,
        v_transaction_id AS transaction_id;
END$$
DELIMITER ;
CALL DepositMoney(2001, 5000);


-- P4 Withdraww Money
-- Requirements: positive amount, active account, sufficient balance, update balance, insert Withdrawal transaction,
-- transaction handling.
-- DROP PROCEDURE IF EXISTS WithdrawMoney;
DELIMITER $$
CREATE PROCEDURE WithdrawMoney(
    IN p_account_id INT,
    IN p_amount DECIMAL(15,2)
)
BEGIN

 DECLARE v_status VARCHAR(20);
    DECLARE v_balance DECIMAL(15,2);
    DECLARE v_new_balance DECIMAL(15,2);
    DECLARE v_transaction_id INT;
    DECLARE v_reference VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    IF p_amount IS NULL OR p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Withdrawal amount must be greater than zero';
    END IF;
    START TRANSACTION;
    SELECT status, balance
    INTO v_status, v_balance
    FROM accounts
    WHERE account_id = p_account_id
    FOR UPDATE;
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Account does not exist';
    END IF;
    IF v_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Account is not active';
    END IF;
    IF v_balance < p_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient balance';
    END IF;
    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_account_id;
    SET v_new_balance = v_balance - p_amount;
    SET v_reference = CONCAT('WDL-', UUID());
    INSERT INTO transactions
        (account_id, transaction_type, amount,
         transaction_date, reference_no)
    VALUES
        (p_account_id, 'Withdrawal', p_amount,
         CURRENT_TIMESTAMP, v_reference);
    SET v_transaction_id = LAST_INSERT_ID();
    COMMIT;
     SELECT
        p_account_id AS account_id,
        p_amount AS amount,
        v_new_balance AS new_balance,
        'Withdrawal successful' AS status,
        v_transaction_id AS transaction_id;
END$$
DELIMITER ;
CALL WithdrawMoney(2001, 2000);

-- P5 Transfer Funds
-- This is the core transaction procedure: validate both accounts, prevent same-account transfers, check balance, debit +
-- credit + record both sides, and commit or roll back as one transaction.
-- DROP PROCEDURE IF EXISTS TransferFunds;

DELIMITER $$
CREATE PROCEDURE TransferFunds(
    IN p_from_account_id INT,
    IN p_to_account_id INT,
    IN p_amount DECIMAL(15,2)
)
BEGIN
    DECLARE v_from_status VARCHAR(20);
    DECLARE v_to_status VARCHAR(20);
    DECLARE v_from_balance DECIMAL(15,2);
    DECLARE v_to_balance DECIMAL(15,2);
    DECLARE v_from_new_balance DECIMAL(15,2);
    DECLARE v_to_new_balance DECIMAL(15,2);
    DECLARE v_reference VARCHAR(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    IF p_amount IS NULL OR p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer amount must be greater than zero';
    END IF;
    IF p_from_account_id = p_to_account_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Source and destination accounts cannot be the same';
    END IF;
    START TRANSACTION;
    -- Lock both account rows in a consistent order. 
    SELECT account_id
    FROM accounts
    WHERE account_id IN (p_from_account_id, p_to_account_id)
    ORDER BY account_id
    FOR UPDATE;
    SELECT status, balance
    INTO v_from_status, v_from_balance
    FROM accounts
    WHERE account_id = p_from_account_id;
    IF v_from_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Source account does not exist';
    END IF;
    SELECT status, balance
    INTO v_to_status, v_to_balance
    FROM accounts
    WHERE account_id = p_to_account_id;
    IF v_to_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Destination account does not exist';
    END IF;
    IF v_from_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Source account is not active';
    END IF;
    IF v_to_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Destination account is not active';
    END IF;
    IF v_from_balance < p_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient balance in source account';
    END IF;
    SET v_reference = CONCAT('TRF-', UUID());
    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_from_account_id;
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_to_account_id;
    INSERT INTO transactions
        (account_id, transaction_type, amount,
         transaction_date, reference_no)
    VALUES
        (p_from_account_id, 'Transfer', p_amount,
         CURRENT_TIMESTAMP, CONCAT('TRF-OUT-', v_reference));
    INSERT INTO transactions
        (account_id, transaction_type, amount,
         transaction_date, reference_no)
    VALUES
        (p_to_account_id, 'Transfer', p_amount,
         CURRENT_TIMESTAMP, CONCAT('TRF-IN-', v_reference));
    SET v_from_new_balance = v_from_balance - p_amount;
    SET v_to_new_balance = v_to_balance + p_amount;
    COMMIT;
    SELECT
        v_reference AS reference_number,
        p_from_account_id AS from_account_id,
        v_from_new_balance AS from_balance,
        p_to_account_id AS to_account_id,
        v_to_new_balance AS to_balance,
        'Transfer successful' AS transfer_status;
END$$
DELIMITER ;
CALL TransferFunds(2001, 2002, 3000);


-- P6 GetAccountStatement
-- Returns deposits, withdrawals and transfers for the requested account/date range, ordered by transaction date, with a
-- running balance.
-- DROP PROCEDURE IF EXISTS GetAccountStatement;
DELIMITER $$
CREATE PROCEDURE GetAccountStatement(
    IN p_account_id INT,
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_opening_balance DECIMAL(15,2);
    IF p_start_date IS NULL OR p_end_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Start date and end date are required';
    END IF;
    IF p_start_date > p_end_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Start date cannot be after end date';
    END IF;
    SELECT status, balance
    INTO v_status, v_opening_balance
    FROM accounts
    WHERE account_id = p_account_id;
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Account does not exist';
    END IF;
    /*
      Starting balance is reconstructed as:
      current balance - net effect of all transactions.
      For transfer rows, TRF-OUT decreases and TRF-IN increases.
    */
    SELECT
        a.account_id,
        a.balance
        - COALESCE((
            SELECT SUM(
                CASE
                    WHEN t.transaction_type = 'Deposit'
                        THEN t.amount
                    WHEN t.transaction_type = 'Withdrawal'
                        THEN -t.amount
                    WHEN t.transaction_type = 'Transfer'
                         AND t.reference_no LIKE 'TRF-IN-%'
                        THEN t.amount
                    WHEN t.transaction_type = 'Transfer'
                         AND t.reference_no LIKE 'TRF-OUT-%'
                        THEN -t.amount
                    ELSE 0
                END
            )
            FROM transactions t
            WHERE t.account_id = a.account_id
        ), 0) AS calculated_opening_balance
    INTO @statement_opening_balance
    FROM accounts a
    WHERE a.account_id = p_account_id;
    SELECT
        t.transaction_id,
        t.transaction_date,
        t.transaction_type,
        t.amount,
        t.reference_no,
        (
            @statement_opening_balance +
            SUM(
                CASE
                    WHEN t.transaction_type = 'Deposit'
                        THEN t.amount
                    WHEN t.transaction_type = 'Withdrawal'
                        THEN -t.amount
                    WHEN t.transaction_type = 'Transfer'
                         AND t.reference_no LIKE 'TRF-IN-%'
                        THEN t.amount
                    WHEN t.transaction_type = 'Transfer'
                         AND t.reference_no LIKE 'TRF-OUT-%'
                END
                        THEN -t.amount
                    ELSE 0
            ) OVER (
                ORDER BY t.transaction_date, t.transaction_id
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )
        ) AS running_balance
    FROM transactions t
    WHERE t.account_id = p_account_id
      AND t.transaction_date >= p_start_date
      AND t.transaction_date < DATE_ADD(p_end_date, INTERVAL 1 DAY)
    ORDER BY t.transaction_date, t.transaction_id;
END$$
DELIMITER ;
CALL GetAccountStatement(
    2001,
    '2026-09-01',
    '2026-09-30'
);

--BONUS: Get customer financial summary
-- Returns active-account count, total balance, total deposits, total withdrawals and most recent transaction date.
-- DROP PROCEDURE IF EXISTS GetCustomerFinancialSummary;

DELIMITER $$
CREATE PROCEDURE GetCustomerFinancialSummary(
    IN p_customer_id INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM customers
        WHERE customer_id = p_customer_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer does not exist';
    END IF;
    SELECT
        c.customer_id,
        c.customer_name,
        COUNT(DISTINCT CASE
            WHEN a.status = 'Active' THEN a.account_id
        END) AS active_account_count,
        COALESCE(SUM(CASE
            WHEN a.status = 'Active' THEN a.balance
            ELSE 0
        END), 0.00) AS total_balance,
        COALESCE(SUM(CASE
            WHEN t.transaction_type = 'Deposit'
                THEN t.amount
            ELSE 0
        END), 0.00) AS total_deposits,
        COALESCE(SUM(CASE
            WHEN t.transaction_type = 'Withdrawal'
                THEN t.amount
            ELSE 0
        END), 0.00) AS total_withdrawals,
        MAX(t.transaction_date) AS most_recent_transaction_date
    FROM customers c
    LEFT JOIN accounts a
        ON c.customer_id = a.customer_id
    LEFT JOIN transactions t
        ON a.account_id = t.account_id
    WHERE c.customer_id = p_customer_id
    GROUP BY c.customer_id, c.customer_name;
END$$
DELIMITER ;
CALL GetCustomerFinancialSummary(101);


-- Verification Queries
DESCRIBE customers;
DESCRIBE accounts;
DESCRIBE transactions;
DESCRIBE beneficiaries;-- Check minimum sample data
SELECT COUNT(*) AS customer_count FROM customers;
SELECT COUNT(*) AS account_count FROM accounts;
SELECT COUNT(*) AS transaction_count FROM transactions;
SELECT COUNT(*) AS beneficiary_count FROM beneficiaries;-- View balances
SELECT account_id, customer_id, account_type, balance, status
FROM accounts
ORDER BY account_id;-- View transactions
SELECT *
FROM transactions
ORDER BY transaction_date, transaction_id;-- Procedure 1
CALL CreateCustomer(
    'Test Customer',
    '9999999999',
    'test.customer@example.com',
    'Pune'
);-- Procedure 2
CALL OpenAccount(101, 'Savings', 10000);-- Procedure 3
CALL DepositMoney(2001, 5000);-- Procedure 4
CALL WithdrawMoney(2001, 2000);-- Procedure 5
CALL TransferFunds(2001, 2002, 3000);-- Procedure 6
CALL GetAccountStatement(
    2001,
    '2026-09-01',
    '2026-09-30'
);-- Bonus
CALL GetCustomerFinancialSummary(101);--Negative test cases
CALL CreateCustomer(
    'Duplicate Test',
    '8888888888',
    'amit@gmail.com',
    'Mumbai'
);-- Invalid account type: should fail
CALL OpenAccount(101, 'Salary', 5000);-- Negative opening deposit: should fail
CALL OpenAccount(101, 'Savings', -100);-- Invalid deposit amount: should fail
CALL DepositMoney(2001, 0);-- Insufficient withdrawal: should fail
CALL WithdrawMoney(2001, 999999999);-- Same-account transfer: should fail
CALL TransferFunds(2001, 2001, 1000);-- Insufficient transfer: should fail
CALL TransferFunds(2001, 2002, 999999999);


