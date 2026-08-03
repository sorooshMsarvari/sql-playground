SELECT order_id, order_date, status
FROM orders
WHERE order_date BETWEEN DATE '2024-03-01' AND DATE '2024-05-31'
  AND status NOT IN ('cancelled', 'refunded')
ORDER BY order_date, order_id;

