WITH monthly AS (
    SELECT date_trunc('month', o.order_date)::date AS month_start,
           sum(oi.quantity * oi.unit_price * (1 - oi.discount)) AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
      AND o.order_date >= DATE '2024-01-01'
      AND o.order_date < DATE '2025-01-01'
    GROUP BY date_trunc('month', o.order_date)::date
)
SELECT month_start,
       round(monthly_revenue, 2) AS monthly_revenue,
       round(sum(monthly_revenue) OVER (
           ORDER BY month_start
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ), 2) AS running_revenue
FROM monthly
ORDER BY month_start;

