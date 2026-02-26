DELIMITER $$

CREATE PROCEDURE populate_transactions_history_realistic()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE total INT DEFAULT 10000;

    DECLARE rand_account INT;
    DECLARE rand_customer INT;
    DECLARE rand_branch INT;
    DECLARE rand_type ENUM('Deposit','Withdrawal','Transfer','Loan_payment');
    DECLARE rand_mode ENUM('Cash','Cheque','Online','ATM','NEFT');
    DECLARE amt DECIMAL(15,2);
    DECLARE open_bal DECIMAL(15,2);
    DECLARE close_bal DECIMAL(15,2);
    DECLARE transaction_date DATETIME;  -- use table column name

    -- Temporary table to hold last balances per account
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_balances (
        account_id INT PRIMARY KEY,
        last_balance DECIMAL(15,2)
    );

    -- Initialize last balances for all accounts
    INSERT INTO temp_balances(account_id, last_balance)
    SELECT account_id, ROUND(1000 + (RAND()*99000),2) FROM Accounts;

    WHILE i <= total DO
        -- Random account and customer
        SET rand_account = (SELECT account_id FROM Accounts ORDER BY RAND() LIMIT 1);
        SET rand_customer = (SELECT customer_id FROM Customers ORDER BY RAND() LIMIT 1);
        SET rand_branch = (SELECT branch_id FROM Accounts WHERE account_id = rand_account);

        -- Random transaction type and mode
        SET rand_type = ELT(FLOOR(1 + RAND()*4), 'Deposit','Withdrawal','Transfer','Loan_payment');
        SET rand_mode = ELT(FLOOR(1 + RAND()*5), 'Cash','Cheque','Online','ATM','NEFT');

        -- Random transaction amount
        SET amt = ROUND(100 + (RAND()*90000), 2);

        -- Get previous balance
        SET open_bal = (SELECT last_balance FROM temp_balances WHERE account_id = rand_account);

        -- Calculate closing balance
        IF rand_type = 'Deposit' THEN
            SET close_bal = open_bal + amt;
        ELSE
            SET close_bal = GREATEST(open_bal - amt, 0);
        END IF;

        -- Random transaction date/time in last 2 years
        SET transaction_date = DATE_ADD(
                                DATE_ADD(
                                    DATE_ADD(
                                        DATE_ADD(CURDATE(), INTERVAL -FLOOR(RAND()*730) DAY),
                                        INTERVAL FLOOR(RAND()*24) HOUR
                                    ),
                                    INTERVAL FLOOR(RAND()*60) MINUTE
                                ),
                                INTERVAL FLOOR(RAND()*60) SECOND
                              );

        -- Insert into table
        INSERT INTO Transactions_History(
            customer_id, branch_id, account_id,
            transaction_type, transaction_amount,
            opening_balance, closing_balance,
            transaction_date, transaction_mode
        )
        VALUES(
            rand_customer, rand_branch, rand_account,
            rand_type, amt,
            open_bal, close_bal,
            transaction_date, rand_mode
        );

        -- Update last balance
        UPDATE temp_balances
        SET last_balance = close_bal
        WHERE account_id = rand_account;

        SET i = i + 1;
    END WHILE;

    -- Clean up
    DROP TEMPORARY TABLE temp_balances;
END$$

DELIMITER ;


DROP PROCEDURE IF EXISTS populate_transactions_history_realistic;

-- 1️⃣ Delete old transactions safely
SET SQL_SAFE_UPDATES = 0;
DELETE FROM Transactions_History;
ALTER TABLE Transactions_History AUTO_INCREMENT = 1;
SET SQL_SAFE_UPDATES = 1;

-- 2️⃣ Drop old procedure if it exists
DROP PROCEDURE IF EXISTS populate_transactions_history_realistic;

-- 3️⃣ Create new procedure
DELIMITER $$

CREATE PROCEDURE populate_transactions_history_realistic()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE total INT DEFAULT 10000;

    DECLARE rand_account INT;
    DECLARE rand_customer INT;
    DECLARE rand_branch INT;
    DECLARE rand_type ENUM('Deposit','Withdrawal','Transfer','Loan_payment');
    DECLARE rand_mode ENUM('Cash','Cheque','Online','ATM','NEFT');
    DECLARE amt DECIMAL(15,2);
    DECLARE open_bal DECIMAL(15,2);
    DECLARE close_bal DECIMAL(15,2);
    DECLARE transaction_date DATETIME;

    -- Temporary table to hold last balances per account
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_balances (
        account_id INT PRIMARY KEY,
        last_balance DECIMAL(15,2)
    );

    -- Initialize last balances for all accounts
    INSERT INTO temp_balances(account_id, last_balance)
    SELECT account_id, ROUND(1000 + (RAND()*99000),2) FROM Accounts;

    WHILE i <= total DO
        -- Random account and customer
        SET rand_account = (SELECT account_id FROM Accounts ORDER BY RAND() LIMIT 1);
        SET rand_customer = (SELECT customer_id FROM Customers ORDER BY RAND() LIMIT 1);
        SET rand_branch = (SELECT branch_id FROM Accounts WHERE account_id = rand_account);

        -- Random transaction type and mode
        SET rand_type = ELT(FLOOR(1 + RAND()*4), 'Deposit','Withdrawal','Transfer','Loan_payment');
        SET rand_mode = ELT(FLOOR(1 + RAND()*5), 'Cash','Cheque','Online','ATM','NEFT');

        -- Random transaction amount
        SET amt = ROUND(100 + (RAND()*90000), 2);

        -- Get previous balance
        SET open_bal = (SELECT last_balance FROM temp_balances WHERE account_id = rand_account);

        -- Calculate closing balance
        IF rand_type = 'Deposit' THEN
            SET close_bal = open_bal + amt;
        ELSE
            SET close_bal = GREATEST(open_bal - amt, 0);
        END IF;

        -- Random transaction date/time in last 2 years
        SET transaction_date = DATE_ADD(
                                DATE_ADD(
                                    DATE_ADD(
                                        DATE_ADD(CURDATE(), INTERVAL -FLOOR(RAND()*730) DAY),
                                        INTERVAL FLOOR(RAND()*24) HOUR
                                    ),
                                    INTERVAL FLOOR(RAND()*60) MINUTE
                                ),
                                INTERVAL FLOOR(RAND()*60) SECOND
                              );

        -- Insert transaction into table
        INSERT INTO Transactions_History(
            customer_id, branch_id, account_id,
            transaction_type, transaction_amount,
            opening_balance, closing_balance,
            transaction_date, transaction_mode
        )
        VALUES(
            rand_customer, rand_branch, rand_account,
            rand_type, amt,
            open_bal, close_bal,
            transaction_date, rand_mode
        );

        -- Update last balance for the account
        UPDATE temp_balances
        SET last_balance = close_bal
        WHERE account_id = rand_account;

        SET i = i + 1;
    END WHILE;

    -- Clean up temporary table
    DROP TEMPORARY TABLE temp_balances;
END$$

DELIMITER ;

-- 4️⃣ Call the procedure to generate 10,000 realistic transactions
CALL populate_transactions_history_realistic();

-- 5️⃣ Check sample transactions
SELECT * FROM Transactions_History ORDER BY transaction_date DESC LIMIT 20;

-- 6️⃣ Total transactions count
SELECT COUNT(*) FROM Transactions_History;
-- 1️⃣ Delete old loans safely
SET SQL_SAFE_UPDATES = 0;
DELETE FROM Loans;
ALTER TABLE Loans AUTO_INCREMENT = 1;
SET SQL_SAFE_UPDATES = 1;

-- 2️⃣ Drop old procedure if exists
DROP PROCEDURE IF EXISTS populate_loans_realistic;

-- 3️⃣ Create new procedure
DELIMITER $$

CREATE PROCEDURE populate_loans_realistic()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE total INT DEFAULT 500;

    DECLARE rand_customer INT;
    DECLARE rand_branch INT;
    DECLARE loan_type ENUM('Personal','Home','Vehicle','Education','Business','Other');
    DECLARE loan_amount DECIMAL(15,2);
    DECLARE interest_rate DECIMAL(5,2);
    DECLARE duration_months INT;
    DECLARE loan_start DATETIME;
    DECLARE loan_end DATETIME;
    DECLARE emi DECIMAL(15,2);
    DECLARE loan_status ENUM('Approved','Disbursed','Closed','Defaulted','Pending');

    WHILE i <= total DO
        -- Random customer and branch
        SET rand_customer = (SELECT customer_id FROM Customers ORDER BY RAND() LIMIT 1);
        SET rand_branch = (SELECT branch_id FROM Branches ORDER BY RAND() LIMIT 1);

        -- Random loan type
        SET loan_type = ELT(FLOOR(1 + RAND()*6), 'Personal','Home','Vehicle','Education','Business','Other');

        -- Random loan amount based on type
        CASE loan_type
            WHEN 'Personal' THEN SET loan_amount = ROUND(50000 + RAND()*450000,2);
            WHEN 'Home' THEN SET loan_amount = ROUND(500000 + RAND()*4500000,2);
            WHEN 'Vehicle' THEN SET loan_amount = ROUND(200000 + RAND()*1800000,2);
            WHEN 'Education' THEN SET loan_amount = ROUND(50000 + RAND()*950000,2);
            WHEN 'Business' THEN SET loan_amount = ROUND(500000 + RAND()*4500000,2);
            ELSE SET loan_amount = ROUND(100000 + RAND()*900000,2);
        END CASE;

        -- Random annual interest rate 6% to 15%
        SET interest_rate = ROUND(6 + RAND()*9,2);

        -- Random duration in months based on type
        CASE loan_type
            WHEN 'Personal' THEN SET duration_months = FLOOR(6 + RAND()*36); -- 6–42 months
            WHEN 'Home' THEN SET duration_months = FLOOR(60 + RAND()*240);   -- 5–25 years
            WHEN 'Vehicle' THEN SET duration_months = FLOOR(12 + RAND()*48); -- 1–5 years
            WHEN 'Education' THEN SET duration_months = FLOOR(12 + RAND()*60);-- 1–5 years
            WHEN 'Business' THEN SET duration_months = FLOOR(12 + RAND()*120);-- 1–10 years
            ELSE SET duration_months = FLOOR(6 + RAND()*60);
        END CASE;

        -- Random loan start date in last 5 years
        SET loan_start = DATE_ADD(
                            DATE_ADD(
                                DATE_ADD(
                                    DATE_ADD(CURDATE(), INTERVAL -FLOOR(RAND()*1825) DAY),
                                    INTERVAL FLOOR(RAND()*24) HOUR
                                ),
                                INTERVAL FLOOR(RAND()*60) MINUTE
                            ),
                            INTERVAL FLOOR(RAND()*60) SECOND
                         );

        -- Loan end date = start date + duration_months
        SET loan_end = DATE_ADD(loan_start, INTERVAL duration_months MONTH);

        -- Calculate EMI
        -- Formula: EMI = P*r*(1+r)^n / ((1+r)^n -1)
        -- Monthly interest rate in decimal
        SET @r = interest_rate / 12 / 100;
        SET @n = duration_months;
        SET emi = ROUND(loan_amount * @r * POW(1+@r,@n) / (POW(1+@r,@n)-1),2);

        -- Random loan status
        SET loan_status = ELT(FLOOR(1 + RAND()*5), 'Approved','Disbursed','Closed','Defaulted','Pending');

        -- Insert into Loans table
        INSERT INTO Loans(
            customer_id, branch_id, loan_type, loan_amount,
            interest_rate, loan_start_date, loan_end_date,
            emi_amount, outstanding_balance, loan_status
        )
        VALUES(
            rand_customer, rand_branch, loan_type, loan_amount,
            interest_rate, loan_start, loan_end,
            emi, loan_amount, loan_status
        );

        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- 4️⃣ Call the procedure
CALL populate_loans_realistic();

-- 5️⃣ Check sample loans
SELECT * FROM Loans ORDER BY loan_start_date DESC LIMIT 20;

-- 6️⃣ Count total loans
SELECT COUNT(*) FROM Loans;


