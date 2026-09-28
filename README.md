# Banking & Transaction Management System

A MySQL-based Banking and Transaction Management System developed as part of the JForce Solutions SQL Developer – Stored Procedure Interview Task.

The project demonstrates how stored procedures can be used to implement banking operations such as customer registration, account opening, deposits, withdrawals, fund transfers, and account statements while maintaining data validation, transaction consistency, and accurate account balances.

---

## 📌 Table of Contents

- [Project Overview](#-project-overview)
- [Objective](#-objective)
- [Technology Used](#-technology-used)
- [System Features](#-system-features)
- [Database Architecture](#-database-architecture)
- [Database Tables](#-database-tables)
- [Stored Procedures](#-stored-procedures)
- [Validation and Business Rules](#-validation-and-business-rules)
- [Transaction Management](#-transaction-management)
- [Project Structure](#-project-structure)
- [Database Setup](#-database-setup)
- [How to Execute](#-how-to-execute)
- [Testing](#-testing)
- [Verification Queries](#-verification-queries)
- [Expected Workflow](#-expected-workflow)
- [Key SQL Concepts Demonstrated](#-key-sql-concepts-demonstrated)
- [Future Improvements](#-future-improvements)
- [Conclusion](#-conclusion)
- [Author](#-author)

---

# 📖 Project Overview

The Banking & Transaction Management System is a relational database application implemented using MySQL Stored Procedures.

The purpose of this project is to simulate basic banking operations at the database level.

The system manages:

1. Customer registration
2. Bank account creation
3. Money deposits
4. Money withdrawals
5. Fund transfers between accounts
6. Account transaction statements

The system also maintains transaction history and applies business validations before performing financial operations.

---

# 🎯 Objective

The primary objective of this project is to demonstrate practical knowledge of:

- MySQL database design
- Relational database relationships
- Primary keys and foreign keys
- Constraints
- Stored procedures
- Input parameters
- Conditional logic
- Validation
- Error handling
- Aggregate functions
- JOIN operations
- Transaction management
- COMMIT and ROLLBACK
- Financial transaction history
- Account balance management

The implementation focuses on maintaining data consistency and preventing invalid banking operations.

---

# 🛠 Technology Used

| Technology              | Purpose                                |
| ----------------------- | -------------------------------------- |
| MySQL                   | Database management system             |
| SQL                     | Database queries and operations        |
| MySQL Stored Procedures | Business logic implementation          |
| Git/GitHub              | Version control and project submission |

---

# ⭐ System Features

## Customer Management

- Register new customers
- Prevent duplicate customer emails
- Maintain customer status
- Generate customer IDs

## Account Management

- Open Savings or Current accounts
- Validate customer existence
- Validate account type
- Maintain account balance
- Maintain account status

## Deposit Management

- Deposit money into an account
- Validate deposit amount
- Validate account status
- Update account balance
- Create transaction history

## Withdrawal Management

- Withdraw money from an account
- Validate withdrawal amount
- Validate account status
- Check sufficient balance
- Update account balance
- Create transaction history

## Fund Transfer

- Transfer money between two accounts
- Validate source account
- Validate destination account
- Prevent same-account transfers
- Check sufficient balance
- Debit source account
- Credit destination account
- Record transaction history
- Use COMMIT/ROLLBACK for consistency

## Account Statement

- Retrieve account transactions
- Filter transactions by date range
- Display transaction type
- Display transaction amount
- Display transaction reference
- Display transaction date
- Display account balance/details

---

# 🗄 Database Architecture

The system contains four main tables:

```text
                    +----------------+
                    | CUSTOMERS |
                    +----------------+
                    | customer_id PK |
                    | customer_name |
                    | phone |
                    | email |
                    | city |
                    | status |
                    +-------+--------+
                            |
                            | 1 : N
                            |
                    +-------v--------+
                    | ACCOUNTS |
                    +----------------+
                    | account_id PK |
                    | customer_id FK |
                    | account_type |
                    | balance |
                    | opened_date |
                    | status |
                    +-------+--------+
                            |
                            | 1 : N
                            |
                    +-------v----------+
                    | TRANSACTIONS |
                    +------------------+
                    | transaction_id PK|
                    | account_id FK |
                    | transaction_type |
                    | amount |
                    | transaction_date |
                    | reference_no |
                    +------------------+

                    +------------------+
                    | BENEFICIARIES |
                    +------------------+
                    | beneficiary_id PK|
                    | account_id FK |
                    | beneficiary_name |
                    | beneficiary_acct |
                    | status |
                    +------------------+

```
