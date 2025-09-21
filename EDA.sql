use classicmodels;

-- List all customers from USA
	SELECT *
	FROM customers;

-- List all customers from USA
	SELECT customername
	FROM customers
	WHERE country = 'USA';

-- Show all products where stock is less than 500 units
	SELECT *
	FROM products
	WHERE quantityinstock < 500;

-- Find employees working in the Paris office
	SELECT *
	FROM employees
	WHERE officecode = 4;

 -- Get orders with status = 'Cancelled
	SELECT *
	FROM orders
	WHERE STATUS = 'cancelled';

-- List all customers whose credit limit > 100000
	SELECT *
	FROM customers
	WHERE creditlimit > 100000;

-- List all customers whose credit limit > 100000
	SELECT *
	FROM customers
	WHERE salesrepemployeenumber IS NULL;

-- Show all orders placed in 2004
	SELECT *
	FROM orders
	WHERE year(shippeddate) = 2004;


-- JOINS 


--  Show all orders along with the customer name
	SELECT *
	FROM orders
	INNER JOIN customers using (customernumber);

-- Show each customer with their sales representative’s name
	SELECT customerName
	FROM customers
	INNER JOIN orders using (customernumber)
	WHERE salesRepEmployeeNumber IS NOT NULL;

-- Find all employees and the office city they work in
	SELECT *
	FROM employees
	INNER JOIN offices using (officecode);

 -- Show each order with its ordered products and quantities
	SELECT productname,quantityOrdered
	FROM products
	INNER JOIN orderdetails using (productcode);
        
        
  -- List all payments with customer name and country
	SELECT customername,country
	FROM customers
	INNER JOIN payments using (customernumber);        
        
-- Show all customers who have never placed an order
	SELECT customernumber,customername
	FROM customers
	LEFT JOIN orders using (customernumber)
	WHERE ordernumber IS NULL;

-- Find employees who don’t manage anyone
	SELECT *
	FROM employees
	RIGHT JOIN offices using (officecode)
	WHERE reportsto IS NULL;        
        
        
-- Aggregates & Grouping


-- Count how many customers each country has
	SELECT country,
	count(customernumber) each_customers
	FROM customers
	GROUP BY country;

-- Find the total sales amount for each customer
	SELECT customernumber,customername,
	sum(quantityordered * priceeach) total_sales_amount
	FROM customers
	JOIN orders using (customernumber)
	JOIN orderdetails
	GROUP BY customernumber;


--  Show the average credit limit per country
	SELECT country,
	avg(creditlimit) average
	FROM customers
	GROUP BY country
	ORDER BY average DESC;

--  Find the maximum payment amount per customer
	SELECT customernumber,
	max(amount)
	FROM payments
	GROUP BY customernumber;

-- Count the number of products in each product line
	SELECT productline,
	count(productcode)
	FROM products
	GROUP BY productLine;

-- Find which employee manages the most customers
	SELECT salesRepEmployeeNumber,
	count(customernumber) total
	FROM customers
	GROUP BY salesRepEmployeeNumber
	ORDER BY total limit 1;

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
	SELECT customernumber,
	max(amount) max
	FROM payments
	GROUP BY customernumber
	ORDER BY max DESC limit 0,5;


-- Subqueries & Insights


-- Find customers who made payments greater than the average payment
	SELECT customernumber,amount
	FROM payments p
	WHERE amount > (
		SELECT avg(amount)
		FROM payments);

-- List products that have never been ordered
	SELECT p.productcode, p.productname
	FROM products p
	WHERE p.productcode NOT IN (
		SELECT od.productcode
		FROM orderdetails od);

-- Find the employee with the highest number of direct reports
	SELECT reportsTo,
	count(*)
	FROM employees
	WHERE reportsTo IS NOT NULL
	GROUP BY reportsTo
	ORDER BY count(*) DESC limit 1;

-- Show orders that contain the most expensive product
	SELECT ordernumber,productcode,priceeach
	FROM orderdetails
	WHERE priceEach = (
		SELECT max(priceEach)
		FROM orderdetails);        
        
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
	SELECT customername
	FROM customers
	JOIN orders o using (customernumber)
	WHERE STATUS = 'shipped'
	GROUP BY customerNumber
	HAVING count(ordernumber) > 5;        
        
-- List product lines where the average MSRP > 100
	SELECT productline,
	AVG(MSRP)
	FROM products
	GROUP BY productline
	HAVING avg(MSRP) > 100;        
        
-- Show employees with more than 3 customers assigned
	SELECT salesRepEmployeeNumber,
	count(customernumber)
	FROM customers
	GROUP BY salesRepEmployeeNumber
	HAVING count(salesRepEmployeeNumber) > 3;

-- Display orders where the shippedDate is NULL
	SELECT *
	FROM orders
	WHERE shippeddate IS NULL;

-- Categorize customers by credit limit: High, Medium, Low.
	SELECT customernumber,creditlimit,
	CASE 
		WHEN creditlimit > 100000
			THEN 'High'
		WHEN creditlimit BETWEEN 50000
				AND 99999
			THEN 'Medium'
		ELSE 'Low'
		END category
	FROM customers;

-- Find the top 10 most ordered products
	SELECT ordernumber,
	count(*) AS quantity
	FROM orderdetails
	GROUP BY orderNumber
	ORDER BY quantity DESC limit 10;

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
	SELECT country,
		sum(quantityordered * priceeach) revenue
	FROM customers
	JOIN orders using (customernumber)
	JOIN orderdetails using (ordernumber)
	GROUP BY country
	ORDER BY revenue DESC limit 1; 

 -- Who are the top 5 sales representatives by payments?
	SELECT employeenumber,sum(amount) total
	FROM employees
	JOIN customers c ON employeeNumber = c.salesRepEmployeeNumber
	JOIN payments using (customernumber)
	GROUP BY employeeNumber
	ORDER BY total DESC limit 5; 
 
 -- Which month has the highest number of orders?
	SELECT month(orderDate) mon,
	count(ordernumber) total
	FROM orders
	GROUP BY mon
	ORDER BY total DESC limit 1; 
 
 -- What is the average order size (quantity of products per order)?
	SELECT avg(order_size) avg_order_size
	FROM (
	SELECT ordernumber,
		sum(quantityordered) order_size
	FROM orderdetails
	GROUP BY orderNumber) AS order_totals; 
 
-- Which product has the highest profit margin (MSRP - buyPrice)
	SELECT productcode,productname,
	(MSRP - buyPrice) profit_margin
	FROM products
	ORDER BY profit_margin DESC limit 1;        
        
 -- Which office manages the largest number of customers?
	SELECT o.officecode,o.city,o.country,
	count(c.customernumber) total
	FROM offices o
	JOIN employees e using (officecode)
	JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
	GROUP BY officeCode,city,country
	ORDER BY total DESC limit 1;

-- Who are the most valuable customers (based on payments)?
	SELECT c.customernumber,c.customername,
	sum(p.amount) total
	FROM customers c
	JOIN payments p using (customernumber)
	GROUP BY c.customernumber,c.customername
	ORDER BY total DESC limit 10;

-- Find the trend of sales over years
	SELECT year(orderDate) orderyear,
	sum(quantityOrdered * priceEach) total
	FROM orders
	JOIN orderdetails using (ordernumber)
	GROUP BY orderyear
	ORDER BY orderyear;

 -- Which product line has highest stock but lowest sales?
	SELECT productLine,
	sum(quantityInStock) highstock,
	sum(quantityordered * priceeach) total
	FROM products
	JOIN orderdetails using (productcode)
	GROUP BY productLine
	ORDER BY highstock DESC,total ASC; 
 
  -- Detect customers with zero payments
	SELECT c.customerNumber,c.customername
	FROM customers c
	LEFT JOIN payments p ON c.customernumber = p.customerNumber
	WHERE p.customerNumber IS NULL; 
 
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
    	totalOrdered ASC LIMIT 10; 








