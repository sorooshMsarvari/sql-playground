WITH customer_totals AS (
    SELECT c.customer_id,
           c.company_name,
           sum(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY c.customer_id, c.company_name
), bucketed AS (
    SELECT *,
           ntile(4) OVER (ORDER BY revenue DESC, customer_id) AS value_quartile
    FROM customer_totals
)
SELECT customer_id,
       company_name,
       round(revenue, 2) AS lifetime_revenue,
       value_quartile
FROM bucketed
ORDER BY value_quartile, revenue DESC, customer_id;

