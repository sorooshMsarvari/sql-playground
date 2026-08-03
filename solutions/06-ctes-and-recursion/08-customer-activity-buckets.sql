WITH customer_activity AS (
    SELECT c.customer_id,
           count(o.order_id) FILTER (WHERE o.status = 'completed') AS completed_orders
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id
), bucketed AS (
    SELECT customer_id,
           CASE
               WHEN completed_orders = 0 THEN 'none'
               WHEN completed_orders = 1 THEN 'one'
               ELSE 'repeat'
           END AS activity_bucket
    FROM customer_activity
)
SELECT activity_bucket, count(*) AS customer_count
FROM bucketed
GROUP BY activity_bucket
ORDER BY CASE activity_bucket WHEN 'none' THEN 1 WHEN 'one' THEN 2 ELSE 3 END;

