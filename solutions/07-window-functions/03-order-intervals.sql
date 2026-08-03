WITH timeline AS (
    SELECT customer_id,
           order_id,
           order_date,
           lag(order_date) OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS previous_order_date
    FROM orders
    WHERE status = 'completed'
)
SELECT customer_id,
       order_id,
       order_date,
       previous_order_date,
       order_date - previous_order_date AS days_since_previous
FROM timeline
ORDER BY customer_id, order_date, order_id;

