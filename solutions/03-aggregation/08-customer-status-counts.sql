SELECT c.customer_id,
       c.company_name,
       count(o.order_id) AS total_orders,
       count(o.order_id) FILTER (WHERE o.status = 'completed') AS completed_orders,
       count(o.order_id) FILTER (WHERE o.status IN ('pending', 'processing')) AS open_orders
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.company_name
ORDER BY c.customer_id;

