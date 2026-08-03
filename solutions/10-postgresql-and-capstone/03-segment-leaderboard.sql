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
customer_metrics AS (
    SELECT c.segment,
           c.customer_id,
           c.company_name,
           coalesce(c.metadata ->> 'channel', 'unknown') AS acquisition_channel,
           count(*) AS completed_orders,
           sum(ot.revenue) AS lifetime_revenue,
           min(ot.order_date) AS first_order,
           max(ot.order_date) AS last_order
    FROM customers c
    JOIN order_totals ot ON ot.customer_id = c.customer_id
    GROUP BY c.segment, c.customer_id, c.company_name, c.metadata
),
ranked AS (
    SELECT cm.*,
           dense_rank() OVER (
               PARTITION BY segment
               ORDER BY lifetime_revenue DESC
           ) AS revenue_rank
    FROM customer_metrics cm
)
SELECT segment,
       revenue_rank,
       customer_id,
       company_name,
       acquisition_channel,
       completed_orders,
       round(lifetime_revenue, 2) AS lifetime_revenue,
       first_order,
       last_order
FROM ranked
WHERE revenue_rank <= 2
ORDER BY segment, revenue_rank, customer_id;

