WITH order_totals AS (
    SELECT o.order_id,
           sum(oi.quantity * oi.unit_price * (1 - oi.discount)) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY o.order_id
),
payment_totals AS (
    SELECT p.order_id, sum(p.amount) AS paid_total
    FROM payments p
    WHERE p.status = 'succeeded'
    GROUP BY p.order_id
)
SELECT ot.order_id,
       round(ot.order_total, 2) AS order_total,
       round(coalesce(pt.paid_total, 0), 2) AS paid_total,
       round(coalesce(pt.paid_total, 0) - ot.order_total, 2) AS difference
FROM order_totals ot
LEFT JOIN payment_totals pt ON pt.order_id = ot.order_id
WHERE abs(coalesce(pt.paid_total, 0) - ot.order_total) >= 0.01
ORDER BY abs(coalesce(pt.paid_total, 0) - ot.order_total) DESC, ot.order_id;

