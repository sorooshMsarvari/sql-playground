WITH timeline AS (
    SELECT customer_id,
           order_id,
           order_date,
           lead(order_date) OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS next_order_date
    FROM orders
    WHERE status = 'completed'
)
SELECT customer_id,
       order_id,
       order_date,
       next_order_date,
       next_order_date - order_date AS days_until_next
FROM timeline
ORDER BY customer_id, order_date, order_id;

