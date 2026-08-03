WITH months AS (
    SELECT month_start::date
    FROM generate_series(DATE '2024-01-01', DATE '2024-12-01', INTERVAL '1 month') AS month_start
)
SELECT m.month_start,
       count(DISTINCT o.order_id) AS completed_orders,
       round(coalesce(sum(oi.quantity * oi.unit_price * (1 - oi.discount)), 0), 2) AS revenue
FROM months m
LEFT JOIN orders o
       ON o.order_date >= m.month_start
      AND o.order_date < m.month_start + INTERVAL '1 month'
      AND o.status = 'completed'
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY m.month_start
ORDER BY m.month_start;

