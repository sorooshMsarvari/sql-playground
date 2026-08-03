SELECT o.order_id,
       c.company_name,
       p.product_name,
       oi.quantity,
       oi.unit_price,
       oi.discount
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'completed'
  AND o.order_date >= DATE '2025-01-01'
  AND o.order_date < DATE '2026-01-01'
ORDER BY o.order_id, p.product_name;

