SELECT o.order_id,
       round(sum(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue,
       sum(oi.quantity) AS units
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY o.order_id
ORDER BY revenue DESC, o.order_id;

