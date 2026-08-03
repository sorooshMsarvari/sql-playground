SELECT oi.product_id,
       o.order_id,
       o.order_date,
       oi.quantity,
       sum(oi.quantity) OVER (
           PARTITION BY oi.product_id
           ORDER BY o.order_date, o.order_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_units
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status = 'completed'
ORDER BY oi.product_id, o.order_date, o.order_id;

