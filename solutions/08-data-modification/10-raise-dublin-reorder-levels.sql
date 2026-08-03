UPDATE inventory i
SET reorder_level = i.reorder_level + 2
FROM warehouses w
WHERE w.warehouse_id = i.warehouse_id
  AND w.warehouse_name = 'Dublin Hub'
  AND i.units_in_stock < i.reorder_level;

