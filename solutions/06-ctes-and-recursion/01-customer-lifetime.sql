WITH order_totals AS (
    SELECT o.order_id,
           o.customer_id,
           o.order_date,
           sum(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY o.order_id, o.customer_id, o.order_date
),
customer_totals AS (
    SELECT customer_id,
           count(*) AS completed_orders,
           sum(revenue) AS lifetime_revenue,
           min(order_date) AS first_order,
           max(order_date) AS last_order
    FROM order_totals
    GROUP BY customer_id
)
SELECT c.customer_id,
       c.company_name,
       coalesce(ct.completed_orders, 0) AS completed_orders,
       round(coalesce(ct.lifetime_revenue, 0), 2) AS lifetime_revenue,
       ct.first_order,
       ct.last_order
FROM customers c
LEFT JOIN customer_totals ct ON ct.customer_id = c.customer_id
ORDER BY lifetime_revenue DESC, c.customer_id;

