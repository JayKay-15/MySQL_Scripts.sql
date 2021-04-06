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

--









