SELECT c.customer_id,
       c.company_name,
       round(sum(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS completed_revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY c.customer_id, c.company_name
HAVING sum(oi.quantity * oi.unit_price * (1 - oi.discount)) > 1500
ORDER BY completed_revenue DESC, c.customer_id;

