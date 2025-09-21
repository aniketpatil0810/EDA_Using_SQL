use classicmodels;

-- List all customers from USA
		select * from customers;


-- List all customers from USA
		select customername from customers where country='USA';


-- Show all products where stock is less than 500 units
		select * from products where quantityinstock <500 ;


-- Find employees working in the Paris office
		select * from employees where officecode=4;


 -- Get orders with status = 'Cancelled
		select * from orders where status='cancelled';


-- List all customers whose credit limit > 100000
		select * from customers where creditlimit > 100000;


-- List all customers whose credit limit > 100000
		select * from customers where salesrepemployeenumber IS null;


-- Show all orders placed in 2004
		select * from orders where year(shippeddate) = 2004;



-- JOINS 


--  Show all orders along with the customer name
		select * from orders inner join customers using(customernumber);


-- Show each customer with their sales representative’s name
		select customerName from customers inner join orders using(customernumber) where salesRepEmployeeNumber IS NOT NULL;


-- Find all employees and the office city they work in
		select * from employees inner join offices using(officecode);


 -- Show each order with its ordered products and quantities
		select productname,quantityOrdered from products inner join orderdetails using(productcode);
        
        
  -- List all payments with customer name and country
		select customername,country from customers inner join payments using(customernumber);
        
        
-- Show all customers who have never placed an order
		select customernumber,customername from customers left join orders using(customernumber) where ordernumber IS NULL;


-- Find employees who don’t manage anyone
		select	* from employees right join offices using(officecode) where reportsto IS NULL;
        
        
        
-- Aggregates & Grouping


-- Count how many customers each country has
		select country,count(customernumber) each_customers from customers group by country  ;


-- Find the total sales amount for each customer
	SELECT customernumber,customername,
	sum(quantityordered * priceeach) total_sales_amount
	FROM customers
	JOIN orders using (customernumber)
	JOIN orderdetails
	GROUP BY customernumber;


--  Show the average credit limit per country
		select country,avg(creditlimit) average from customers group by country order by average desc;


--  Find the maximum payment amount per customer
		select customernumber,max(amount) from payments group by customernumber;


-- Count the number of products in each product line
		select productline,count(productcode) from products group by productLine;


-- Find which employee manages the most customers
		select salesRepEmployeeNumber,count(customernumber) total from customers group by salesRepEmployeeNumber order by total limit 1;


--  Get the monthly sales totals for 2004
	SELECT year(o.orderdate) year,
	month(o.orderdate) month,
	sum(od.quantityordered * od.priceeach) total
	FROM orders o
	INNER JOIN orderdetails od ON o.ordernumber = od.ordernumber
	WHERE year(o.orderdate) = 2004
	GROUP BY year(o.orderdate),
	month(o.orderdate)
	ORDER BY month(o.orderdate);


-- Find the top 5 customers by total payments
		select customernumber,max(amount) max from payments group by customernumber order by max desc limit 0,5;



-- Subqueries & Insights


-- Find customers who made payments greater than the average payment
		select customernumber,amount from payments p where amount > (select avg(amount) from payments);


-- List products that have never been ordered
		select p.productcode,p.productname from products p where p.productcode not in (select od.productcode from orderdetails od);


-- Find the employee with the highest number of direct reports
		select reportsTo,count(*) FROM employees where reportsTo IS NOT NULL group by reportsTo order by count(*) desc limit 1 ;


-- Show orders that contain the most expensive product
		select ordernumber,productcode,priceeach from orderdetails where priceEach = (select max(priceEach) from orderdetails);
        
        
 -- List the top 3 offices with the highest total sales
		SELECT o.officeCode, o.city, o.country,
			SUM(od.quantityOrdered * od.priceEach) AS totalSales
				FROM offices o
		JOIN employees e ON o.officeCode = e.officeCode
		JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
		JOIN orders ord ON c.customerNumber = ord.customerNumber
		JOIN orderdetails od ON ord.orderNumber = od.orderNumber
		GROUP BY o.officeCode, o.city, o.country;



-- Stored Procedures
-- 	Create a procedure to get all orders by a given customer
delimiter $$
create procedure GetOrderByCustomer(IN p_customernumber INT)
begin
select * from orders o where o.customernumber=p_customernumber;
END $$

CALL GetOrderByCustomer(141)$$



-- Create a procedure to find total sales between two dates
create procedure salebetweentwodates(IN p_StartDate date,p_EndDate date)
begin
select sum(quantityordered * priceeach) as total FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber where o.orderdate between p_StartDate AND p_EndDate;
END $$ 

CALL salebetweentwodates('2004-01-01', '2004-12-31')$$


 -- Build a procedure that shows the best-selling product line
CREATE PROCEDURE GetBestSellingProductLine()
BEGIN
    SELECT pl.productLine,
           SUM(od.quantityOrdered * od.priceEach) AS totalSales
    FROM orderdetails od
    JOIN products p ON od.productCode = p.productCode
    JOIN productlines pl ON p.productLine = pl.productLine
    GROUP BY pl.productLine
    ORDER BY totalSales DESC
    LIMIT 1;
END $$

CALL GetBestSellingProductLine()$$



-- Create a procedure to display all customers handled by an employee
create procedure GetEmpHandledByCustomers(IN p_employeenumber int)
begin
select * from customers c where c.salesRepEmployeeNumber=p_employeenumber;
END $$

CALL GetEmpHandledByCustomers(1370)$$



-- Write a procedure to calculate yearly revenue given an input year.
CREATE PROCEDURE GetYearlyRevenue (IN p_year INT)
BEGIN
    SELECT SUM(od.quantityOrdered * od.priceEach) AS totalRevenue
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE YEAR(o.orderDate) = p_year;
END $$

CALL GetYearlyRevenue(2003)$$



-- Advanced Clauses
-- Find customers who placed more than 5 orders.
		select customername from customers join orders o using(customernumber) where status='shipped' group by customerNumber having count(ordernumber) >5 ;
        
        
-- List product lines where the average MSRP > 100
		select productline,AVG(MSRP) from products group by productline having avg(MSRP) >100;
        
        
-- Show employees with more than 3 customers assigned
		select salesRepEmployeeNumber,count(customernumber) from customers group by salesRepEmployeeNumber having count(salesRepEmployeeNumber) >3;


-- Display orders where the shippedDate is NULL
		select * from orders where shippeddate IS NULL;


-- Categorize customers by credit limit: High, Medium, Low.
		select customernumber,creditlimit, CASE when creditlimit > 100000 then 'High' when creditlimit between 50000 and 99999 then 'Medium' else 'Low' END category from customers; 


-- Find the top 10 most ordered products
		select ordernumber,count(*) as quantity from orderdetails group by orderNumber order by quantity desc limit 10 ;


-- Show the revenue contribution % of each product line.
SELECT p.productLine,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS productline_revenue,
    ROUND(SUM(od.quantityOrdered * od.priceEach) * 100 / 
          (SELECT SUM(od2.quantityOrdered * od2.priceEach) 
           FROM orderdetails od2), 2) AS revenue_percentage
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.productLine
ORDER BY revenue_percentage DESC;



 -- Business Insights
 
 
 -- Which country generates the most revenue?
		select country,sum(quantityordered*priceeach) revenue from customers join orders using(customernumber) join orderdetails using(ordernumber) group by country order by revenue desc limit 1; 
 

 -- Who are the top 5 sales representatives by payments?
		select employeenumber,sum(amount) total from employees join customers c on employeeNumber=c.salesRepEmployeeNumber join payments using(customernumber) group by employeeNumber order by total desc limit 5;
 
 
 -- Which month has the highest number of orders?
		select month(orderDate) mon,count(ordernumber) total from orders group by mon order by total desc limit 1;
 
 
 -- What is the average order size (quantity of products per order)?
		select avg(order_size) avg_order_size from (select ordernumber,sum(quantityordered) order_size from orderdetails group by orderNumber) as order_totals;
 
 
-- Which product has the highest profit margin (MSRP - buyPrice)
		select productcode,productname, (MSRP-buyPrice) profit_margin from products order by profit_margin desc limit 1;
        
        
 -- Which office manages the largest number of customers?
		select o.officecode,o.city,o.country,count(c.customernumber) total from offices o join employees e using(officecode) join customers c on e.employeeNumber=c.salesRepEmployeeNumber group by officeCode,city,country order by total desc limit 1;


-- Who are the most valuable customers (based on payments)?
		select c.customernumber,c.customername,sum(p.amount) total from customers c join payments p using(customernumber) group by c.customernumber,c.customername order by total desc limit 10;


-- Find the trend of sales over years
		select year(orderDate) orderyear,sum(quantityOrdered*priceEach) total from orders join orderdetails using(ordernumber) group by orderyear order by orderyear;


 -- Which product line has highest stock but lowest sales?
		select productLine,sum(quantityInStock) highstock,sum(quantityordered * priceeach) total from products join orderdetails using(productcode) group by productLine order by highstock desc,total asc;
 
 
  -- Detect customers with zero payments
		select c.customerNumber,c.customername from customers c left join payments p on c.customernumber=p.customerNumber where p.customerNumber IS NULL;
 
 
-- Find the slowest-moving products (very few orders)
SELECT 
    p.productCode,
    p.productName,
    COALESCE(SUM(od.quantityOrdered), 0) AS totalOrdered
FROM 
    products p
LEFT JOIN 
    orderdetails od 
    ON p.productCode = od.productCode
GROUP BY 
    p.productCode, p.productName
ORDER BY 
    totalOrdered ASC
LIMIT 10; 








