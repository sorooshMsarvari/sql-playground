-- Find customers whose completed-order revenue is greater than 1500.
-- Columns: customer_id, company_name, completed_revenue (rounded to 2 decimals)
-- Sort by completed_revenue descending, then customer_id.
 -- TODO

SELECT c.customer_id,
       c.company_name,
       round(sum(oi.quantity * oi.unit_price * (1-oi.discount)), 2) AS completed_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY c.customer_id,
         c.company_name
HAVING sum(oi.quantity * oi.unit_price * (1-oi.discount)) > 1500
ORDER BY completed_revenue DESC, c.customer_id;