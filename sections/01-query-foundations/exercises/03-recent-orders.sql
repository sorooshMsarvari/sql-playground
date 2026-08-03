-- Return the five most recent completed orders placed during calendar year 2024.
-- Columns: order_id, customer_id, order_date
-- Sort newest order_date first, then highest order_id first.

-- TODO
SELECT order_id, customer_id, order_date
FROM orders
WHERE status = 'completed'AND
  order_date >= '2024-01-01'AND
  order_date < '2025-01-01'
ORDER BY order_date DESC, order_id DESC
LIMIT 5;

