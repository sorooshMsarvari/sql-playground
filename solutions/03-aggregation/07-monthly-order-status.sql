SELECT date_trunc('month', order_date)::date AS month_start,
       count(*) AS total_orders,
       count(*) FILTER (WHERE status = 'completed') AS completed_orders,
       count(*) FILTER (WHERE status = 'cancelled') AS cancelled_orders
FROM orders
WHERE order_date >= DATE '2024-01-01'
  AND order_date < DATE '2025-01-01'
GROUP BY date_trunc('month', order_date)::date
ORDER BY month_start;

