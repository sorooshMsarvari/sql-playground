SELECT order_id, customer_id, order_date
FROM orders
WHERE status = 'completed'
  AND order_date >= DATE '2024-01-01'
  AND order_date < DATE '2025-01-01'
ORDER BY order_date DESC, order_id DESC
LIMIT 5;

