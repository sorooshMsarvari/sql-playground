SELECT c.customer_id,
       c.company_name,
       count(o.order_id) AS order_count,
       min(o.order_date) AS first_order,
       max(o.order_date) AS last_order
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.company_name
ORDER BY c.customer_id;

