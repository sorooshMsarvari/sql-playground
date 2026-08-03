SELECT training.assert_true(
    (SELECT count(*) = (SELECT count(*) FROM orders WHERE status = 'completed')
     FROM shop.completed_order_totals),
    'view has exactly one row per completed order'
);

WITH expected AS (
    SELECT o.order_id,
           o.customer_id,
           o.order_date,
           round(sum(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_amount
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY o.order_id, o.customer_id, o.order_date
), differences AS (
    (SELECT * FROM shop.completed_order_totals EXCEPT ALL SELECT * FROM expected)
    UNION ALL
    (SELECT * FROM expected EXCEPT ALL SELECT * FROM shop.completed_order_totals)
)
SELECT training.assert_true(
    NOT EXISTS (SELECT 1 FROM differences),
    'view rows and discounted totals are exact'
);

