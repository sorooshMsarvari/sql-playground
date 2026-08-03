SELECT w.warehouse_id,
       w.warehouse_name,
       p.product_id,
       p.product_name
FROM warehouses w
CROSS JOIN products p
LEFT JOIN inventory i
       ON i.warehouse_id = w.warehouse_id
      AND i.product_id = p.product_id
WHERE p.discontinued = false
  AND i.product_id IS NULL
ORDER BY w.warehouse_id, p.product_id;

