-- Return customer type (bronze, silver, gold) based on loyalty points

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

--


                

