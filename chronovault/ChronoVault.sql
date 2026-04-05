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

select * from branches; 
select count(*) from branches; -- 50
select * from employees;
select count(*) from employees; -- 370
select * from customers;
select count(*) from customers; -- 315 
select * from accounts;
select count(*) from accounts; -- 416
select * from Bank_transactions; 
select count(*) from Bank_transactions; -- 10000
select * from balances; 
select count(*) from balances; -- 416
select * from Liabilities;
select count(*) from Liabilities; -- 416
select * from transactions_history;
select count(*) from transactions_history; -- 10000
select * from loans;
select count(*) from loans; -- 500
-- creating view for customers accounts and balances
create view customer_summary as 
select c.customer_id,c.customer_name,c.email_id,c.contact_no,br.branch_name,br.branch_city,a.account_id,a.account_type,a.account_status,b.current_balance
from customers as c
join branches as br on c.branch_id=br.branch_id
join accounts as a on c.customer_id=a.customer_id
join balances as b on a.account_id =b.account_id;
select * from customer_summary;
-- this query will find the customer whose account is active 
select * from customer_summary where account_status='Active';
-- this query will find the customer whose balance is greater than 10 thousand
select * from customer_summary where current_balance>10000;
-- list of all customers with their branch name
select c.customer_name,b.branch_name
from customers as c
join branches as b
on c.branch_id=b.branch_id;
-- show customers who opened account after 2022
select c.customer_id,a.opened_at 
from customers as c
join accounts as a
on c.customer_id=a.customer_id
where a.opened_at>= '2023-01-01' ;
-- numbers of customer in each branch
select b.branch_name,count(*) as total_customers
from customers as c
join branches as b
on c.branch_id=b.branch_id
group by b.branch_name;
-- the branches having more than 5 customers
select b.branch_name,count(*) as total_customers
from customers as c
join branches as b
on c.branch_id=b.branch_id
group by b.branch_name
having count(*)>5;
-- the accounts which are still pending
select account_id,account_status
from accounts 
where account_status='Pending';
-- total number of accounts as account_type
select account_type, count(*) as total_account
from accounts 
group by account_type;
-- the customers who do not have any account
select c.customer_id,c.customer_name
from customers as c
 left join accounts as a
on c.customer_id=a.customer_id
where a.account_id is null;
-- the customers who deposits more than 10,000
select c.customer_id , c.customer_name from customers as c
where exists(
        select 1 from accounts as a
        join bank_transactions as t on a.account_id = t.account_id
        where a.customer_id = c.customer_id
        and t.transaction_type ='Deposit' and t.transaction_amount > 10000);
-- all accounts with customer name,branch name and account status
select c.customer_name,b.branch_name,a.account_id,a.account_status
from branches as b
join customers as c 
on b.branch_id=c.branch_id
join accounts as a
on c.customer_id=a.customer_id;
-- The customers who have more than 1 accounts
select c.customer_id,c.customer_name,count(*) total_accounts
from customers as c
join accounts as a
on c.customer_id =a.customer_id
group by c.customer_id,c.customer_name
having count(*) >1;
-- The empoloyees working in the same branch as customer 'Amit Sharma'
select e.employee_id,e.employee_name
from employees as e
where e.branch_id = (
   select branch_id from customers where customer_name ='Amit Sharma' limit 1 );
-- All accounts whose balance is zero
select account_id from balances where current_balance =0;
-- All customers who never made any transactions
select distinct  c.customer_id, c.customer_name
from  customers c
join  accounts a on c.customer_id = a.customer_id
left join bank_transactions t on a.account_id = t.account_id
where t.transaction_id is null;
-- Detect Suspicious Accounts (Fraud Detection)
select account_id, date(transaction_date) as transaction_day, sum(transaction_amount) as total_withdrawal
from bank_transactions
where transaction_type ='Withdrawal'
group by account_id, date(transaction_date)
having sum(transaction_amount)>50000;
-- Top valuable customers
select c.customer_id,c.customer_name,coalesce(sum(t.transaction_amount),0)+ coalesce(sum(l.loan_amount),0) as total_flow
from customers as c
left join accounts as a on c.customer_id = a.customer_id
left join bank_transactions as t on a.account_id= t.account_id and t.transaction_type='Deposit'
left join loans as l on c.customer_id =l.customer_id 
group by c.customer_id,c.customer_name
order by total_flow desc
limit 5;
-- account with no transaction in last 6 months
select a.account_id,b.current_balance
from accounts as a 
join balances as b
on a.account_id = b.account_id
left join bank_transactions as t 
on a.account_id = t.account_id and t.transaction_date >= current_date - interval 6 month
where b.current_balance >10000
and t.transaction_id is null;
-- fraud detection of accounts who withdrawal more than 50000 in single day
select c.customer_id,c.customer_name,a.account_id,b.branch_name,date(t.transaction_date) as transaction_day ,sum(t.transaction_amount) as total_withdrawal
from bank_transactions as t
join accounts as a on t.account_id=a.account_id
join customers as c on a.customer_id=c.customer_Id
join branches as b on c.branch_id = b.branch_id 
where t.transaction_type ='Withdrawal'
group by c.customer_id,c.customer_name,a.account_id,b.branch_name,date(t.transaction_date)
having sum(t.transaction_amount)>50000;
-- customers whose balances is above the branch average
select c.customer_id,
       c.customer_name,
       bal.current_balance
from customers c
join accounts a on c.customer_id = a.customer_id
join balances bal on a.account_id = bal.account_id
where bal.current_balance > (
    select avg(current_balance)
    from balances
);
-- Customer Category Based on Balances
select c.customer_id,c.customer_name,b.current_balance,
case
  when b.current_balance>500000 then 'Premium'
  when b.current_balance between 100000 and 500000 then 'Regular'
  else 'Basic'
end as customer_category
from customers as c
join accounts as a on c.customer_id=a.customer_id
join balances as b on a.account_id=b.account_id;
-- Loan Risk Classification
select c.customer_id,c.customer_name,l.loan_id,l.outstanding_balance,
case
   when l.outstanding_balance>500000 then 'High Risk'
   when l.outstanding_balance between 200000 and 500000 then 'Medium Risk'
   else 'Low Risk'
end as Loan_repayment
from customers as c
join loans as l on c.customer_id= l.customer_id;
-- Account Activity Status
select a.account_id,max(transaction_date) as last_transaction,
case
    when max(transaction_date)>=CURRENT_DATE - INTERVAL 30 DAY then 'Active'
    when max(transaction_date) Between CURRENT_DATE - INTERVAL  180 DAY AND CURRENT_DATE - INTERVAL  90 DAY then 'Dormant'
    else 'Inactive'
end as activity_status
from accounts as a
left join bank_transactions as t on a.account_id=t.account_id
group by a.account_id;
-- Rank customers within each category
select c.customer_id,c.customer_name,b.current_balance,
rank() over (partition by 
                           case
                               when b.current_balance >500000 then 'Premium'
                               when b.current_balance >=100000 then 'Regular'
                               else 'Basic'
							end 
                            order by b.current_balance DESC
                            ) as rank_in_category
from customers as c
join accounts as a on c.customer_id=a.customer_id
join balances as b on a.account_id=b.account_id
where a.account_status ='Active';
-- top 3 branches who has highes total_withdrawal amount considering only active accounts for one year
select b.branch_name,sum(t.transaction_amount)as total_withdrawal,count(c.customer_id) as total_customers
from bank_transactions as t
join accounts as a on t.account_id=a.account_id
join customers as c on a.customer_id=c.customer_Id
join branches as b on c.branch_id = b.branch_id 
where t.transaction_type='Withdrawal' and a.account_status ='Active'
group by b.branch_name
order by total_withdrawal DESC 
limit 3;
-- finding customers who have loans but their account balance is less than the emi amount 
select c.customer_name,br.branch_name,l.loan_type,b.current_balance,l.emi_amount
from customers as c
join branches as br on br.branch_id=c.branch_id
join accounts as a on a.customer_id=c.customer_id
join balances as b on b.account_id=a.account_id
join loans as l on l.customer_id=c.customer_id
where b.current_balance<l.emi_amount
order by l.emi_amount DESC;
-- finding customers who have more than one loan and there atleast one loan is defaulted and there total outstanding balances is greater than 5000000
select c.customer_name,br.branch_name,count(distinct l.loan_id) as total_loans,sum(outstanding_balance) as total_outstanding_balance,'Critical Risk' as risk_label
from customers as c
join branches as br on br.branch_id=c.branch_id
join loans as l on c.customer_id=l.customer_id
where exists (
        select 1 
        from loans as l2
        where l2.customer_id=c.customer_id and l2.loan_status='Defaulted'
        )
group by c.customer_name,br.branch_name
having count(distinct l.loan_id)>1
and sum(l.outstanding_balance)>500000
order by total_outstanding_balance desc;

