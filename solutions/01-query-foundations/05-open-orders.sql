SELECT order_id, order_date, status, shipping_country
FROM orders
WHERE status IN ('pending', 'processing')
  AND order_date >= DATE '2024-07-01'
ORDER BY order_date, order_id;

