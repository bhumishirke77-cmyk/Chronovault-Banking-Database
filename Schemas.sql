CREATE DATABASE Chronovault;
USE Chronovault;
CREATE TABLE Branches(
   branch_id INT AUTO_INCREMENT PRIMARY KEY,
   branch_name VARCHAR(30) NOT NULL,
   branch_country VARCHAR(20) NOT NULL,
   branch_state VARCHAR(30) NOT NULL,
   branch_city VARCHAR(20) NOT NULL,
   branch_created_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   ifsc_code CHAR(11) NOT NULL UNIQUE
   );
CREATE TABLE Employees(
   employee_id INT AUTO_INCREMENT PRIMARY KEY,
   employee_name VARCHAR(30) NOT NULL,
   employee_salary DECIMAL(10,2) ,CHECK(employee_salary>0),
   joining_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   email_id VARCHAR(100)  NOT NULL,
   contact_no VARCHAR(15) NOT NULL,
   employee_department ENUM('IT','HR','Finance','Loan','Support','Other') DEFAULT 'Other',
   status ENUM('Active','Resigned','Terminated','On Leave') DEFAULT 'Active',
   branch_id INT NOT NULL ,
   FOREIGN KEY (branch_id) REFERENCES Branches(branch_id)
   );
CREATE TABLE Customers(
   customer_id INT AUTO_INCREMENT PRIMARY KEY,
   branch_id INT NOT NULL,
   customer_name VARCHAR(100) NOT NULL,
   contact_no VARCHAR(15) NOT NULL UNIQUE ,
   date_of_birth DATE NOT NULL,
   address VARCHAR(200) NOT NULL,
   email_id VARCHAR(100) NOT NULL UNIQUE,
   customer_since DATE NOT NULL,
   FOREIGN KEY (branch_id) REFERENCES Branches(branch_id)
   );
CREATE TABLE  Accounts(
   account_id INT AUTO_INCREMENT PRIMARY KEY,
   account_type VARCHAR(30) NOT NULL,
   opened_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   account_status ENUM('Active','Closed','Frozen','Pending') DEFAULT 'Pending',
   credit_limit DECIMAL(15,2)  NULL,
   branch_id INT NOT NULL,
   customer_id INT NOT NULL,
   currency CHAR(3) DEFAULT 'INR',
   FOREIGN KEY (branch_id) REFERENCES Branches(branch_id),
   FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
   );
CREATE TABLE Bank_Transactions(
   transaction_id INT AUTO_INCREMENT PRIMARY KEY,
   account_id INT NOT NULL,
   transaction_type ENUM('Deposit','Withdrawal','Transfer','Loan_payment')NOT NULL ,
   transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   transaction_mode ENUM('Cash','Cheque','Online','ATM','NEFT'),
   transaction_amount DECIMAL(15,2) NOT NULL ,CHECK (transaction_amount >0),
   remarks VARCHAR(350),
   currency CHAR(3) NOT NULL DEFAULT 'INR',
   FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
   );
CREATE TABLE Balances(
   account_id INT PRIMARY KEY,
   current_balance DECIMAL(15,2) NOT NULL ,CHECK(current_balance >=0),
   currency CHAR(3) NOT NULL DEFAULT 'INR',
   previous_balance DECIMAL(15,2),
   last_updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
   );
CREATE TABLE Liabilities( -- WHAT CUSTOMERS OWS TO BANK
   liability_id INT AUTO_INCREMENT PRIMARY KEY,
   account_id INT NOT NULL,
   customer_id INT NOT NULL,
   amount Decimal(15,2) CHECK(amount>=0),
   interest_rate DECIMAL(5,2) CHECK(interest_rate>0), -- interest= amount* interest_rate/100
   liability_type ENUM('Loan','Credit','Overdraft') NOT NULL,
   maturity_date DATETIME NOT NULL,
   FOREIGN KEY (account_id) REFERENCES Accounts(account_id),
   FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
   ); -- each liability belong to 1 account+ 1 customes
CREATE TABLE Transactions_History(
   history_id INT AUTO_INCREMENT PRIMARY KEY,
   customer_id INT NOT NULL,
   branch_id INT NOT NULL,
   account_id INT NOT NULL,
   transaction_type ENUM('Deposit','Withdrawal','Transfer','Loan_payment') NOT NULL,
   transaction_amount DECIMAL(15,2),
   opening_balance DECIMAL(15,2),
   closing_balance DECIMAL(15,2),
   transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   transaction_mode ENUM('Cash','Cheque','Online','ATM','NEFT'),
   currency CHAR(3) NOT NULL DEFAULT 'INR',
   FOREIGN KEY (branch_id) REFERENCES Branches(branch_id),
   FOREIGN KEY (account_id) REFERENCES Accounts(account_id),
   FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
   );
CREATE TABLE Loans(
   loan_id INT AUTO_INCREMENT PRIMARY KEY,
   customer_id INT NOT NULL,
   branch_id INT NOT NULL,
   loan_type ENUM('Personal','Home','Vehicle','Education','Business','Other') NOT NULL,
   loan_amount DECIMAL(15,2) NOT NULL,
   interest_rate DECIMAL(5,2) NOT NULL,
   loan_start_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   loan_end_date DATETIME NOT NULL,
   emi_amount DECIMAL(15,2) NOT NULL,
   outstanding_balance DECIMAL(15,2) NOT NULL,
   collateral VARCHAR(200),
   loan_status ENUM('Approved','Disbursed','Closed','Defaulted','Pending') NOT NULL,
   FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
   FOREIGN KEY (branch_id) REFERENCES Branches(branch_id)
   );
CREATE INDEX idx_customers_branch ON Customers(branch_id);
CREATE INDEX idx_accounts_customer ON Accounts(customer_id);
CREATE INDEX idx_transactions_account ON Bank_transactions(account_id);
