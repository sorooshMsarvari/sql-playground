SELECT c.customer_id, c.company_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.customer_id = c.customer_id
      AND oi.quantity >= 5
)
ORDER BY c.customer_id;

