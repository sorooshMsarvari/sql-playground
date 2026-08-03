SELECT date_trunc('quarter', o.order_date)::date AS quarter_start,
       count(DISTINCT o.order_id) AS completed_orders,
       round(sum(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'completed'
  AND o.order_date >= DATE '2024-01-01'
  AND o.order_date < DATE '2025-01-01'
GROUP BY date_trunc('quarter', o.order_date)::date
ORDER BY quarter_start;

