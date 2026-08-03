WITH monthly AS (
    SELECT date_trunc('month', o.order_date)::date AS month_start,
           sum(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
      AND o.order_date >= DATE '2024-01-01'
      AND o.order_date < DATE '2025-01-01'
    GROUP BY date_trunc('month', o.order_date)::date
)
SELECT month_start,
       round(revenue, 2) AS monthly_revenue,
       round(avg(revenue) OVER (
           ORDER BY month_start
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 2) AS moving_average_3m
FROM monthly
ORDER BY month_start;

