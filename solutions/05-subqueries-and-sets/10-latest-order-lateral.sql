SELECT c.customer_id,
       c.company_name,
       latest.order_id AS latest_order_id,
       latest.order_date AS latest_order_date,
       latest.status AS latest_order_status
FROM customers c
LEFT JOIN LATERAL (
    SELECT o.order_id, o.order_date, o.status
    FROM orders o
    WHERE o.customer_id = c.customer_id
    ORDER BY o.order_date DESC, o.order_id DESC
    LIMIT 1
) latest ON true
ORDER BY c.customer_id;

