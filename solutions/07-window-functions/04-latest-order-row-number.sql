WITH ranked_orders AS (
    SELECT o.*,
           row_number() OVER (
               PARTITION BY o.customer_id
               ORDER BY o.order_date DESC, o.order_id DESC
           ) AS rn
    FROM orders o
)
SELECT c.customer_id,
       c.company_name,
       ro.order_id,
       ro.order_date,
       ro.status
FROM ranked_orders ro
JOIN customers c ON c.customer_id = ro.customer_id
WHERE ro.rn = 1
ORDER BY c.customer_id;

