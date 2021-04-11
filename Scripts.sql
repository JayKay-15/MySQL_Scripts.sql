-- Return customer type (bronze, silver, gold) based on loyalty points - UNION

SELECT 
  customer_id,
  first_name,
  points,
  'Bronze' AS type
FROM customers
WHERE points < 2000
UNION
SELECT 
  customer_id,
  first_name,
  points,
  'Silver' AS type
FROM customers
WHERE points BETWEEN 2000 AND 3000
UNION
SELECT 
  customer_id,
  first_name,
  points,
  'Gold' AS type
FROM customers
WHERE points > 3000
ORDER BY first_name

-- Add comments to customers with over 3000 loyalty points

UPDATE orders
SET comments = 'Gold Customer'
WHERE customer_id IN 
	       (SELECT customer_id
                FROM customers
                WHERE points > 3000)
		

-- Customers in Virginia who spent more than $100

SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  sum(oi.quantity * oi.unit_price) AS total_sale
FROM customers c
JOIN orders o USING (customer_id)
JOIN order_items oi USING (order_id)
WHERE state = 'VA'
GROUP BY
  c.customer_id,
  c.first_name,
  c.last_name
HAVING total_sales > 100

-- Select all customer who have purchases product_id 3

SELECT 
  customer_id, 
  first_name, 
  last_name
FROM customers
WHERE customer_id IN (
	SELECT o.customer_id
	FROM order_items oi
    	JOIN orders o USING (order_id)
    	WHERE product_id = 3
)

-- Get invoices larger than the client's average invoice
SELECT *
FROM invoices i
WHERE invoice_total > (
	SELECT AVG(invoice_total)
	FROM invoices
	WHERE client_id = i.client_id
)

-- List of products that have not been ordered
SELECT *
FROM products p
WHERE NOT EXISTS (
	SELECT *
	FROM order_items
	WHERE product_id = p.product_id
)

-- Subqueries in the SELECT clause; finding total, average, different sales

SELECT 
    client_id,
    name,
    (SELECT SUM(invoice_total) 
	FROM invoices
        WHERE client_id = c.client_id) AS total_sales,
    (SELECT AVG(invoice_total)
	FROM invoices) AS average,
    (SELECT total_sales) - (SELECT average) AS difference
FROM clients c
                
-- Subquery in FROM clause; simple query

SELECT *
FROM (
    SELECT 
	client_id,
	name,
	(SELECT SUM(invoice_total) 
		FROM invoices
		WHERE client_id = c.client_id) AS total_sales,
	(SELECT AVG(invoice_total)
		FROM invoices) AS average,
	(SELECT total_sales) - (SELECT average) AS difference
     FROM clients c
) AS sales_summary
WHERE total_sales IS NOT NULL

-- Return customer type (bronze, silver, gold) based on loyalty points - CASE WHEN

SELECT 
    CONCAT(first_name, " ", last_name) AS customer,
    points,
    CASE
	WHEN points > 3000 THEN "Gold"
        WHEN points >= 2000 THEN "Silver"
        ELSE "Bronze"
    END AS loyalty_category
FROM customers
ORDER BY points DESC

-- Create view

CREATE VIEW clients_balance AS
    SELECT c.client_id,
    	   c.name,
	   SUM(invoice_total - payment_total) AS balance
    FROM clients c
    JOIN invoices i USING (client_id)
    GROUP BY client_id, name

-- Create a stored procedure

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_payments`(
	client_id INT, 
	payment_method_id TINYINT
)
BEGIN
    SELECT *
    FROM payments p
    WHERE p.client_id = IFNULL(client_id, p.client_id) 
    AND p.payment_method = IFNULL(payment_method_id, p.payment_method);
END

-- Stored procedure with validation

CREATE DEFINER=`root`@`localhost` PROCEDURE `make_payment`(
    invoice_id INT,
    payment_amount DECIMAL (9,2),
    payment_date DATE
)
BEGIN
	IF payment_amount <= 0 THEN
	SIGNAL SQLSTATE '22003' 
        SET MESSAGE_TEXT = 'Invalid payment amount';
	END IF;
    
UPDATE invoices i
    SET 
	i.payment_total = payment_amount,
        i.payment_date = payment_date
	WHERE i.client_id = client_id;
END

-- Trigger to update invoice table

DELIMITER $$

CREATE TRIGGER payments_after_insert
    AFTER INSERT ON payments 
    FOR EACH ROW 
BEGIN
    UPDATE invoices 
    SET payment_total = payment_total + NEW.amount
    WHERE invoice_id = NEW.invoice_id;
END $$

DELIMITER ;

-- Trigger to remove amount when payment is deleted

DELIMITER $$

CREATE TRIGGER payments_after_delete
    AFTER DELETE ON payments 
    FOR EACH ROW 
BEGIN
    UPDATE invoices 
    SET payment_total = payment_total - OLD.amount
    WHERE invoice_id = OLD.invoice_id;
END $$

DELIMITER ;

-- Creating events

DELIMITER $$

CREATE EVENT yearly_event_stale_audit_rows
ON SCHEDULE 
    EVERY 1 YEAR STARTS '2021-04-10' ENDS '2030-04-10'
DO BEGIN
    DELETE FROM payments_audit
    WHERE action_date < NOW() - INTERVAL 1 YEAR;
END $$

DELIMITER ;

-- Create table

CREATE DATABASE IF NOT EXISTS sql_store2;

USE sql_store2;
CREATE TABLE IF NOT EXISTS customers
(
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR (50) NOT NULL,
    last_name VARCHAR (50) NOT NULL,
    birthdate DATE NOT NULL,
    phone VARCHAR (50) NOT NULL,
    address VARCHAR (50) NOT NULL,
    city VARCHAR (50) NOT NULL,
    state CHAR (2) NOT NULL,
    email VARCHAR (255) NOT NULL UNIQUE,
    points INT NOT NULL DEFAULT 0
);






