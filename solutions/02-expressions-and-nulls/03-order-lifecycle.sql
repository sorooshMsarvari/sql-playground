SELECT order_id,
       order_date,
       shipped_at - order_date AS fulfillment_days,
       CASE
           WHEN status IN ('completed', 'refunded', 'cancelled') THEN 'closed'
           ELSE 'open'
       END AS lifecycle
FROM orders
WHERE order_date >= DATE '2024-04-01'
  AND order_date < DATE '2024-07-01'
ORDER BY order_date, order_id;

