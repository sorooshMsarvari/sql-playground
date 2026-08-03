WITH order_totals AS (
    SELECT o.order_id,
           sum(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY o.order_id
)
SELECT order_id,
       round(revenue, 2) AS revenue,
       round(100 * revenue / sum(revenue) OVER (), 2) AS revenue_percent
FROM order_totals
ORDER BY revenue_percent DESC, order_id;

