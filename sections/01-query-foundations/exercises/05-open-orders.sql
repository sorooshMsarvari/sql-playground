-- Write the query defined in this section's README.
SELECT order_id, order_date, status, shipping_country
FROM orders
WHERE order_date >= DATE '2024-07-01'
  AND status IN ('pending', 'processing')
ORDER BY order_date, order_id;

