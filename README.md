 # Chronovault-Banking-Database
Chronovault is a complete banking database system built in MySql. It simulates real-world banking operations including customer management,transaction processing,loan management, and branch-level analytics.
This system contains:
• 10 Normalized relational tables
•50 Branches
•370 Employees  
•315 Customers
•416 accounts                    
•10,000 Bank_Transactions
•416 Balances
•416 Liabilities
•10,000 Transaction History 
•500 Loans
-- -- -- -- -- -- -- -- -- 
* Concepts Covered
- Database design and normalization
- Primary keys, foreign keys and constraints
- Indexes for query optimization
- Views for reusable query logic
- INNER JOIN, LEFT JOIN across multiple tables
- Subqueries and correlated subqueries
- GROUP BY, HAVING and aggregate functions
- CASE statements for conditional classification
- Window functions — RANK and PARTITION BY
- EXISTS for existence checks
-- -- -- -- -- -- -- -- -- 
* Real-World Query Solution
- Fraud Detection — accounts with suspicious withdrawals in a single day
- EMI Default Risk — customers whose balance is less than their EMI amount
- Critical Risk Detection — customers with multiple defaulted loans
- Customer Segmentation — Premium, Regular and Basic categories
- Loan Risk Classification — High, Medium and Low risk
- Account Activity Status — Active, Dormant and Inactive
- Branch Performance Analysis — top branches by withdrawal volume
- Top Valuable Customers — by total deposits and loan flow
-- -- -- -- -- -- -- -- -- --
* Tools used
- MySQL
- MySQL Workbench
-- -- -- -- -- -- -- -- -- -- 
* Sample Query
  The query detects customers who withdrew more than 50,000INR in a single day
  By joining 4 tables - Flagged as suspicious activity across all the Branches.
```sql
select c.customer_id,c.customer_name,a.account_id,b.branch_name,date(t.transaction_date) as transaction_day ,sum(t.transaction_amount) as total_withdrawal
from bank_transactions as t
join accounts as a on t.account_id=a.account_id
join customers as c on a.customer_id=c.customer_Id
join branches as b on c.branch_id = b.branch_id 
where t.transaction_type ='Withdrawal'
group by c.customer_id,c.customer_name,a.account_id,b.branch_name,date(t.transaction_date)
having sum(t.transaction_amount)>50000;
```
<img width="818" height="233" alt="Screenshot 2026-03-28 at 4 55 11 PM" src="https://github.com/user-attachments/assets/97a2bc89-90dc-46a8-96ea-73935a819bc6" />
* DataBase Schema - ERD
<img width="713" height="1250" alt="ERD" src="https://github.com/user-attachments/assets/a3093d88-4138-4e7d-ae91-83de6030c311" />

* Author
Bhumi


