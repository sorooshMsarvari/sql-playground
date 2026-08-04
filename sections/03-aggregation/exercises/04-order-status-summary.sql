-- Write the query defined in this section's README.

SELECT 
  o.status,     
  count(DISTINCT o.order_id) AS order_count,
  round(sum(oi.quantity * oi.unit_price * (1-oi.discount)), 2) AS gross_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_date >= DATE '2024-01-01'
  AND o.order_date < DATE '2025-01-01'
GROUP BY o.status
ORDER BY o.status;