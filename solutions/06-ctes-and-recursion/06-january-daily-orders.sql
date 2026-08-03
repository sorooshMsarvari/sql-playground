WITH calendar AS (
    SELECT day::date AS calendar_date
    FROM generate_series(DATE '2024-01-01', DATE '2024-01-31', INTERVAL '1 day') AS day
)
SELECT c.calendar_date,
       count(o.order_id) AS total_orders,
       count(o.order_id) FILTER (WHERE o.status = 'completed') AS completed_orders
FROM calendar c
LEFT JOIN orders o ON o.order_date = c.calendar_date
GROUP BY c.calendar_date
ORDER BY c.calendar_date;

