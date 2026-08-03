WITH order_totals AS (
    SELECT o.order_id,
           o.customer_id,
           sum(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY o.order_id, o.customer_id
)
SELECT c.segment,
       count(*) AS completed_orders,
       round(avg(ot.revenue), 2) AS average_order_value,
       round(sum(ot.revenue), 2) AS total_revenue
FROM order_totals ot
JOIN customers c ON c.customer_id = ot.customer_id
GROUP BY c.segment
ORDER BY c.segment;

