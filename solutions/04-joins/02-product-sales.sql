SELECT p.product_id,
       p.product_name,
       coalesce(sum(oi.quantity) FILTER (WHERE o.status = 'completed'), 0) AS sold_units
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN orders o ON o.order_id = oi.order_id
GROUP BY p.product_id, p.product_name
ORDER BY sold_units DESC, p.product_name;

