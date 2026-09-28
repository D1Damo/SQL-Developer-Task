-- Creaating Database:
CREATE DATABASE IF NOT EXISTS jforce_banking;

-- Using the created database
USE jforce_banking;


-- Customer creation
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    CONSTRAINT chk_customer_status
        CHECK (status IN ('Active', 'Inactive'))
);


-- Account Creation:
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    opened_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_account_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT chk_account_type
        CHECK (account_type IN ('Savings', 'Current')),
    CONSTRAINT chk_account_balance
        CHECK (balance >= 0),
    CONSTRAINT chk_account_status
        CHECK (status IN ('Active', 'Blocked'))
);


-- Transactions Created
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reference_no VARCHAR(100) NOT NULL,
    CONSTRAINT fk_transaction_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT chk_transaction_type
        CHECK (transaction_type IN ('Deposit', 'Withdrawal', 'Transfer')),
    CONSTRAINT chk_transaction_amount
        CHECK (amount > 0)
);


-- Benificiaries Created
CREATE TABLE beneficiaries (
    beneficiary_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    beneficiary_name VARCHAR(100) NOT NULL,
    beneficiary_account VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_beneficiary_account
 FOREIGN KEY (account_id) REFERENCES accounts(account_id),
  CONSTRAINT chk_beneficiary_status
        CHECK (status IN ('Active', 'Inactive')));


-- Customers records
INSERT INTO customers
(customer_id, customer_name, phone, email, city, status)
VALUES
(101, 'Amit Sharma', '9876543210', 'amit@gmail.com', 'Mumbai', 'Active'),
(102, 'Neha Shah', '9876543211', 'neha@gmail.com', 'Pune', 'Active'),
(103, 'Rahul Patil', '9876543212', 'rahul@gmail.com', 'Nagpur', 'Active'),
(104, 'Priya Deshmukh', '9876543213', 'priya@gmail.com', 'Nashik', 'Active'),
(105, 'Vikas Joshi', '9876543214', 'vikas@gmail.com', 'Mumbai', 'Active'),
(106, 'Sneha Kulkarni', '9876543215', 'sneha@gmail.com', 'Pune', 'Active'),
(107, 'Rohan Mehta', '9876543216', 'rohan@gmail.com', 'Thane', 'Active'),
(108, 'Pooja Gupta', '9876543217', 'pooja@gmail.com', 'Aurangabad', 'Active');


-- Accounts records
INSERT INTO accounts
(account_id, customer_id, account_type, balance, opened_date, status)
VALUES
(2001, 101, 'Savings', 25000.00, '2026-01-10', 'Active'),
(2002, 102, 'Savings', 18000.00, '2026-01-12', 'Active'),
(2003, 103, 'Current', 45000.00, '2026-02-05', 'Active'),
(2004, 104, 'Savings', 12000.00, '2026-02-10', 'Active'),
(2005, 105, 'Current', 50000.00, '2026-03-01', 'Active'),
(2006, 106, 'Savings', 22000.00, '2026-03-08', 'Active'),
(2007, 107, 'Savings', 15000.00, '2026-04-02', 'Active'),
(2008, 108, 'Current', 30000.00, '2026-04-10', 'Active'),
(2009, 101, 'Current', 35000.00, '2026-05-01', 'Active'),
(2010, 102, 'Current', 28000.00, '2026-05-15', 'Active');


-- Sampple transactions records
INSERT INTO transactions
(account_id, transaction_type, amount, transaction_date, reference_no)
VALUES
(2001, 'Deposit',    10000.00, '2026-09-01 09:10:00', 'DEP-SAMPLE-001'),
(2001, 'Withdrawal',  2000.00, '2026-09-02 11:20:00', 'WDL-SAMPLE-002'),
(2001, 'Deposit',     5000.00, '2026-09-03 10:15:00', 'DEP-SAMPLE-003'),
(2001, 'Withdrawal',  1500.00, '2026-09-04 15:30:00', 'WDL-SAMPLE-004'),
(2001, 'Transfer',    3000.00, '2026-09-05 12:00:00', 'TRF-OUT-SAMPLE-005'),
(2002, 'Deposit',     8000.00, '2026-09-01 10:00:00', 'DEP-SAMPLE-006'),
(2002, 'Withdrawal',  1000.00, '2026-09-02 12:30:00', 'WDL-SAMPLE-007'),
(2002, 'Deposit',     4000.00, '2026-09-03 13:00:00', 'DEP-SAMPLE-008'),
(2002, 'Transfer',    3000.00, '2026-09-05 12:00:00', 'TRF-IN-SAMPLE-005'),
(2003, 'Deposit',    15000.00, '2026-09-01 09:30:00', 'DEP-SAMPLE-009'),
(2003, 'Withdrawal',  5000.00, '2026-09-02 14:00:00', 'WDL-SAMPLE-010'),
(2003, 'Deposit',     7000.00, '2026-09-04 10:30:00', 'DEP-SAMPLE-011'),
(2004, 'Deposit',     6000.00, '2026-09-01 11:00:00', 'DEP-SAMPLE-012'),
(2004, 'Withdrawal',  1000.00, '2026-09-03 16:00:00', 'WDL-SAMPLE-013'),
(2005, 'Deposit',    20000.00, '2026-09-01 09:00:00', 'DEP-SAMPLE-014'),
(2005, 'Withdrawal',  4000.00, '2026-09-02 10:00:00', 'WDL-SAMPLE-015'),
(2005, 'Deposit',     9000.00, '2026-09-04 11:00:00', 'DEP-SAMPLE-016'),
(2006, 'Deposit',     5000.00, '2026-09-01 12:00:00', 'DEP-SAMPLE-017'),
(2006, 'Withdrawal',  2000.00, '2026-09-03 12:00:00', 'WDL-SAMPLE-018'),
(2007, 'Deposit',     7000.00, '2026-09-02 09:00:00', 'DEP-SAMPLE-019'),
(2007, 'Withdrawal',  1500.00, '2026-09-05 09:30:00', 'WDL-SAMPLE-020'),
(2008, 'Deposit',    12000.00, '2026-09-01 10:00:00', 'DEP-SAMPLE-021'),
(2008, 'Withdrawal',  3000.00, '2026-09-04 13:30:00', 'WDL-SAMPLE-022'),
(2009, 'Deposit',    10000.00, '2026-09-02 14:30:00', 'DEP-SAMPLE-023'),
(2010, 'Deposit',     8000.00, '2026-09-03 15:00:00', 'DEP-SAMPLE-024'),
(2010, 'Withdrawal',  2000.00, '2026-09-05 15:30:00', 'WDL-SAMPLE-025');


-- Beneficiaries records
INSERT INTO beneficiaries
(beneficiary_id, account_id, beneficiary_name, beneficiary_account, status)
VALUES
(1, 2001, 'Neha Shah',       'BEN10001', 'Active'),
(2, 2002, 'Rahul Patil',    'BEN10002', 'Active'),
(3, 2003, 'Priya Deshmukh', 'BEN10003', 'Active'),
(4, 2004, 'Vikas Joshi',    'BEN10004', 'Active'),
(5, 2005, 'Sneha Kulkarni', 'BEN10005', 'Active'),
(6, 2006, 'Rohan Mehta',    'BEN10006', 'Active'),
(7, 2007, 'Pooja Gupta',    'BEN10007', 'Active'),
(8, 2008, 'Amit Sharma',    'BEN10008', 'Active');

