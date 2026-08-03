CREATE VIEW shop.completed_order_totals AS
SELECT o.order_id,
       o.customer_id,
       o.order_date,
       round(sum(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_amount
FROM shop.orders o
JOIN shop.order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY o.order_id, o.customer_id, o.order_date;

