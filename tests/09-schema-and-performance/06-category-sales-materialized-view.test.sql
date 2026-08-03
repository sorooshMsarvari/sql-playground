SELECT training.assert_true(
    (SELECT relkind = 'm'
     FROM pg_class
     WHERE oid = 'shop.category_sales_snapshot'::regclass),
    'category_sales_snapshot is a materialized view'
);

WITH expected AS (
    SELECT c.category_id,
           c.category_name,
           coalesce(sum(oi.quantity) FILTER (WHERE o.status = 'completed'), 0) AS completed_units,
           round(coalesce(sum(oi.quantity * oi.unit_price * (1 - oi.discount))
                          FILTER (WHERE o.status = 'completed'), 0), 2) AS completed_revenue
    FROM categories c
    LEFT JOIN products p ON p.category_id = c.category_id
    LEFT JOIN order_items oi ON oi.product_id = p.product_id
    LEFT JOIN orders o ON o.order_id = oi.order_id
    GROUP BY c.category_id, c.category_name
), differences AS (
    (SELECT * FROM shop.category_sales_snapshot EXCEPT ALL SELECT * FROM expected)
    UNION ALL
    (SELECT * FROM expected EXCEPT ALL SELECT * FROM shop.category_sales_snapshot)
)
SELECT training.assert_true(
    NOT EXISTS (SELECT 1 FROM differences),
    'materialized category snapshot has complete and exact sales metrics'
);

