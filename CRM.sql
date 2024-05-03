-- 14.	In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”? 
Alter table bank_churn
rename column Hascrcard to Has_creditcard;
-- answering 7&16 questions and also creating view by combining two big tables to reduce the repeat of joins
create view customer_details as
	select c.*, 
    b.CreditScore,b.Tenure,b.Balance,b.NumOfProducts,b.Has_creditcard,b.IsActiveMember,b.Exited,
    case
    when CreditScore between 800 and 850 then "Excellent"
    when CreditScore between 740 and 799 then "Very Good"
    when CreditScore between 670 and 739 then "Good"
    when CreditScore between 580 and 669 then "Fair"
	when CreditScore between 300 and 579 then "Poor" end as Segment,
    case 
	when Age between 18 and 30 then "18-30"
    when Age between 30 and 50 then "30-50"
    when Age>50 then "50+" end as Age_group
    from customerinfo c 
    join bank_churn b on c.CustomerId=b.CustomerId;
    -- subjective question 9
    select CustomerID,Segment,Age_group from customer_details;
    

/*2.Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year.*/
SELECT BankDOJ,Surname,EstimatedSalary
FROM customerinfo
WHERE YEAR(BankDOJ)= (SELECT YEAR(MAX(BankDOJ)) FROM customer_details) and QUARTER(BankDOJ)=4
ORDER BY EstimatedSalary DESC
LIMIT 5;

-- 3.Calculate the average number of products used by customers who have a credit card
SELECT round(AVG(NumOfProducts),0) as average_products FROM bank_churn
WHERE Has_creditcard = 1;

-- 5.Compare the average credit score of customers who have exited and those who remain.
SELECT e.ExitCategory,avg(b.creditscore)
from bank_churn b 
join exitcustomer e on b.Exited=e.ExitID
group by e.ExitCategory;

-- 6.Which gender has a higher average estimated salary, and how does it relate to the number of active accounts?
select g.GenderCategory,a.ActiveCategory,count(*) as no_of_users, Round(avg(c.EstimatedSalary),2) as Average_Estimatedsalary
from customerinfo c
join bank_churn b on c.CustomerId = b.CustomerId
join activecustomer a on a.ActiveID = b.IsActiveMember
join gender g on c.GenderID = g.GenderID
group by g.GenderCategory,a.ActiveCategory;

-- 7.Segment the customers based on their credit score and identify the segment with the highest exit rate
select Segment,(count(*)/(select count(*) from customer_details)) as highest_exited_rate
from customer_details
where Exited=1
group by Segment
order by highest_exited_rate desc
limit 1;

--  8.Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. 
SELECT g.GeographyLocation,count(*) AS no_of_active_users
FROM customer_details c
JOIN geography g ON c.GeographyID = g.GeographyID
where c.IsActiveMember=1 and c.Tenure>5
GROUP BY g.GeographyLocation
order by no_of_active_users desc
limit 1;

-- 15.	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id.
--  Also, rank the gender according to the average value. (SQL)
SELECT 
	g.GeographyLocation,
    t.GenderCategory,
    avg(c.EstimatedSalary) AS Average_income,
    rank()over(order by avg(c.EstimatedSalary) desc) as `Rank`
FROM customerinfo c 
JOIN geography g ON c.GeographyID = g.GeographyID
join gender t on c.GenderID = t.GenderID
GROUP BY g.GeographyLocation,t.GenderCategory;

-- 16.	Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
select Age_group,avg(Tenure)
from customer_details
where Exited = 1
group by Age_group;

-- 22. CustomerID_Surname
select *,concat(CustomerId," ",Surname) as primarykey from customerinfo;

-- 23.	Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.
select *,(select e.ExitCategory from exitcustomer e where e.ExitID = b.Exited) as ExitCategory from
bank_churn b;

-- 25.	Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.
select c.CustomerID,c.Surname,a.ActiveCategory 
from customer_details c 
join activecustomer a on a.ActiveID = c.IsActiveMember
where Surname like "%on";
