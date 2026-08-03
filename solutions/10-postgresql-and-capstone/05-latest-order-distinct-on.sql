SELECT DISTINCT ON (c.customer_id)
       c.customer_id,
       c.company_name,
       o.order_id,
       o.order_date,
       o.status
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
ORDER BY c.customer_id, o.order_date DESC, o.order_id DESC;

