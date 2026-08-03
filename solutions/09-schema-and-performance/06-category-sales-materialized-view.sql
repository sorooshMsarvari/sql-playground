CREATE MATERIALIZED VIEW shop.category_sales_snapshot AS
SELECT c.category_id,
       c.category_name,
       coalesce(sum(oi.quantity) FILTER (WHERE o.status = 'completed'), 0) AS completed_units,
       round(coalesce(sum(oi.quantity * oi.unit_price * (1 - oi.discount))
                      FILTER (WHERE o.status = 'completed'), 0), 2) AS completed_revenue
FROM shop.categories c
LEFT JOIN shop.products p ON p.category_id = c.category_id
LEFT JOIN shop.order_items oi ON oi.product_id = p.product_id
LEFT JOIN shop.orders o ON o.order_id = oi.order_id
GROUP BY c.category_id, c.category_name;

