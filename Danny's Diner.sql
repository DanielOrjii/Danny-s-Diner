-- All Datasets Exist Within The Dannys_Diner Database Schema

CREATE  Schema Dannys_Diner
Set search_path = Dannys_Diner;

CREATE Table Sales(
Customer_id Varchar(50),
Order_date Date,
Product_id Varchar (50)
);

Insert into Sales Values
('A', '2021-01-01', 1),
('A', '2021-01-01', 2),
('A', '2021-01-07', 2),
('A', '2021-01-10', 3),
('A', '2021-01-11', 3),
('A', '2021-01-11', 3),
('B', '2021-01-01', 2),
('B', '2021-01-02', 2),
('B', '2021-01-04', 1),
('B', '2021-01-11', 1),
('B', '2021-01-16', 3),
('B', '2021-02-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-07', 3);

SELECT *
FROM Sales sa

CREATE Table Menu(
Product_id Varchar (50),
Product_name varchar (50),
Price numeric
)

Insert into Menu Values
(1, 'Sushi', 10),
(2, 'Curry', 15),
(3, 'Ramen', 12);

SELECT *
FROM Menu Mn

CREATE Table Members (
Customer_id Varchar(50),
Join_date Date
);

INSERT into Members Values
('A', '2021-01-07'),
('B', '2021-01-09');

SELECT *
FROM Members Mb

--Total Amount Each Customer Spent  At The Restaurant
Select s.Customer_id, s.Product_id, Sum(Mn.Price) over (PARTITION BY Customer_id) as TotalAmountSpent 
FROM Sales s 
Join Menu Mn 
on s.Product_id = Mn.Product_id

With Danny_sales (customer_id, product_id, TotalAmountSpent) as
(Select s.Customer_id, s.Product_id, 
Sum(Mn.Price) over (PARTITION BY Customer_id) as TotalAmountSpent 
FROM Sales s 
Join Menu Mn 
on s.Product_id = Mn.Product_id
)
SELECT Customer_id, TotalAmountSpent
FROM Danny_sales
Group by Customer_id 
ORDER BY customer_id

-- How Many Days Has Each Customer Visited The Restaurant

SELECT sa.Customer_id, sa.Order_date, COUNT(Order_date) over (PARTITION BY Customer_id) as DaysVisited 
FROM Sales sa

With Days_visited (customer_id, Order_date, DaysVisited) as 
(SELECT sa.Customer_id, sa.Order_date, COUNT(Order_date) over (PARTITION BY Customer_id) as DaysVisited 
FROM Sales sa)
SELECT *
From Days_visited
Group By Customer_id 

-- The First Item Purchased By Each Customer
SELECT Customer_id, m.Product_name, MIN(Order_date) as FirstOrder
FROM Sales s 
Join Menu m 
on s.Product_id = m.Product_id 
GROUP BY Customer_id 

-- Most Purchased Item On The Menu and How Many Times It Was Purchased
SELECT m.Product_name, COUNT(s.Product_id) as TimesPurchased
FROM Sales s  
Join Menu m 
on s.Product_id = m.Product_id 
GROUP BY s.Product_id 
ORDER BY TimesPurchased DESC 

-- Most Popular Item For Each Customer
SELECT  s.Customer_id, m.Product_name, COUNT(m.Product_name) over (PARTITION by Customer_id, m.Product_id) as MostPopularItem
FROM Sales s 
Join Menu m 
on s.Product_id = m.Product_id 
--GROUP BY Customer_id 
ORDER BY Customer_id 

With Popular_Item (customer_id, product_name, MostPopularItem) AS 
(SELECT  s.Customer_id, m.Product_name, COUNT(m.Product_name) over (PARTITION by Customer_id, m.Product_id) as MostPopularItem
FROM Sales s 
Join Menu m 
on s.Product_id = m.Product_id 
--GROUP BY Customer_id 
ORDER BY Customer_id )
SELECT Customer_id, Product_name, Max(MostPopularItem)
FROM Popular_Item
Group by Customer_id 

--Item Purchased First by Customers after Becoming Members
SELECT  s.Customer_id, s.Product_id, s.Order_date, m.Join_date 
FROM Sales s 
Join Members m 
On s.Customer_id = m.Customer_id 
WHERE s.Order_date = m.Join_date or s.Order_date > m.Join_date 
GROUP BY s.Customer_id

WITH First_Purchase (customer_id, product_id, order_date, Join_date) AS 
(SELECT  s.Customer_id, s.Product_id, s.Order_date, m.Join_date 
FROM Sales s 
Join Members m 
On s.Customer_id = m.Customer_id 
WHERE s.Order_date = m.Join_date or s.Order_date > m.Join_date 
GROUP BY s.Customer_id)
SELECT Customer_id, f.product_id, mn.Product_name, Order_date, f.join_date
FROM First_Purchase f
Join Menu mn  
on f.product_id= mn.product_id
ORDER BY Customer_id 

--Item Purcahased Before Becoming Members
SELECT s.Customer_id, Product_id, MAX(s.Order_date) as PurchaseB4Membership, m.Join_date
FROM Sales s  
Join Members m 
On s.Customer_id = m.Customer_id
Where Order_date < m.Join_date 
GROUP BY s.Customer_id  

WITH Item_b4Membership (customer_id, product_id, PurchaseB4Membership, join_date) AS 
(SELECT s.Customer_id, Product_id, MAX(s.Order_date) as PurchaseB4Membership, m.Join_date
FROM Sales s  
Join Members m 
On s.Customer_id = m.Customer_id
Where Order_date < m.Join_date 
GROUP BY s.Customer_id )
SELECT i.Customer_id, i.Product_id, mn.Product_name, i.PurchaseB4Membership, i.join_date
FROM Item_b4Membership i
Join Menu mn 
on i.product_id = mn.Product_id 

--Total Items and Amount Spent for each Member before Membership
SELECT s.customer_id, s.order_date, s.product_id, m.join_date
FROM Sales s 
Join Members m  
on s.Customer_id  = m.Customer_id
Where s.Order_date < m.Join_date  

With TotalItems_MoneySpent (customer_id, order_date, product_id, join_date) AS 
(SELECT s.customer_id, s.order_date, s.product_id, m.join_date
FROM Sales s 
Join Members m  
on s.Customer_id  = m.Customer_id
Where s.Order_date < m.Join_date)
SELECT DISTINCT Tims.Customer_id, Tims.join_date,
COUNT(mn.Product_name) over (PARTITION BY Tims.Customer_id) as Total_Itemsb4Membership, 
Sum(mn.Price) over (PARTITION BY Tims.Customer_id) as Total_Money_Spentb4Membership
FROM TotalItems_MoneySpent Tims
Join menu mn 
on Tims.product_id = mn.Product_id 
--GROUP BY Tims.Customer_id 

--  Each 1$= 10pts and Sushi = 2x points multiplier, How many points would each customer GET 

SELECT Customer_id, m.Product_name, m.Price 
FROM Sales s 
Join Menu m 
on s.Product_id = m.Product_id 

SELECT Customer_id, m.Product_name, m.Price, --SUM(m.Price) over (PARTITION BY Customer_id) as TotalExpenses,
CASE 
	when Product_name= 'Sushi' then m.Price*2
	Else m.Price 
END AS Points4Sushi
FROM Sales s 
Join Menu m 
on s.Product_id = m.Product_id

SELECT Customer_id, a.Product_name, a.Price, a.Points4Sushi, 
CASE 
	WHEN Price > 1 THEN Points4Sushi*10
END as Totalpts
FROM (SELECT Customer_id, m.Product_name, m.Price, --SUM(m.Price) over (PARTITION BY Customer_id) as TotalExpenses,
CASE 
	when Product_name= 'Sushi' then m.Price*2
	Else m.Price 
END AS Points4Sushi
FROM Sales s 
Join Menu m 
on s.Product_id = m.Product_id) a

With Customer_exp (Customer_id, Product_name, Price, Points4Sushi, Totalpts) as
(SELECT Customer_id, a.Product_name, a.Price, a.Points4Sushi, 
CASE 
	WHEN Price > 1 THEN Points4Sushi*10
END as Totalpts
FROM (SELECT Customer_id, m.Product_name, m.Price, --SUM(m.Price) over (PARTITION BY Customer_id) as TotalExpenses,
CASE 
	when Product_name= 'Sushi' then m.Price*2
	Else m.Price 
END AS Points4Sushi
FROM Sales s 
Join Menu m 
on s.Product_id = m.Product_id) a
)
SELECT Customer_id, SUM(Totalpts) as TotalptsPerCustomer
FROM Customer_exp ce
Group by Customer_id

-- Earn 2x pts on all items in the first week they joined including the date joined

SELECT s.Customer_id, s.Order_date, s.Product_id, m.Join_date, COUNT(s.Product_id) over (PARTITION BY s.Customer_id) AS Items
FROM Sales s 
JOIN Members m 
on s.Customer_id = m.Customer_id 
WHERE s.Order_date BETWEEN '2021-01-01' AND '2021-01-16' 

SELECT Customer_id,
CASE 
	WHEN  a.Order_date >= a.Join_date then Items*2 
END as PointsEndofJan
FROM (SELECT s.Customer_id, s.Order_date, s.Product_id, m.Join_date, COUNT(s.Product_id) over (PARTITION BY s.Customer_id) AS Items
FROM Sales s 
JOIN Members m 
on s.Customer_id = m.Customer_id 
WHERE s.Order_date BETWEEN '2021-01-01' AND '2021-01-16'
And  s.Order_date >= m.Join_date) a
GROUP BY a.Customer_id


-- Join All The Things
Select Customer_id, Order_date, m.Product_name, m.Price 
FROM Sales s  
Join Menu m 
On s.Product_id = m.Product_id 

SELECT a.Customer_id, a.Order_date, a.Product_name, a.Price, 
Case
	When a.Order_date >= m2.Join_date then 'Y'
	Else 'N'
END as Members
From (Select Customer_id, Order_date, m.Product_name, m.Price 
FROM Sales s  
Join Menu m 
On s.Product_id = m.Product_id) a 
Full Outer Join Members m2   
On a.customer_id = m2.Customer_id 

-- Rank Of Items Based On Order_Date For Members ONLY 


SELECT b.Customer_id, b.Order_date, b.Product_name, b.Price, b.Members, 
Dense_Rank () over (PARTITION BY b.Customer_id order by Order_date) as Ranking
FROM Members m3 
Full Outer JOIN(SELECT a.Customer_id, a.Order_date, a.Product_name, a.Price, 
Case
	When a.Order_date >= m2.Join_date then 'Y'
	Else 'N'
END as Members
From Members m2 
Full Outer Join (Select Customer_id, Order_date, m.Product_name, m.Price 
FROM Sales s  
Join Menu m 
On s.Product_id = m.Product_id) a 
On a.customer_id = m2.Customer_id
) b 
on b.customer_id = m3.Customer_id 
WHERE b.Order_date >= m3.Join_date

