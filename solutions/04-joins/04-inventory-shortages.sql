SELECT w.warehouse_name,
       p.product_name,
       i.units_in_stock,
       i.reorder_level,
       i.reorder_level - i.units_in_stock AS units_short
FROM inventory i
JOIN warehouses w ON w.warehouse_id = i.warehouse_id
JOIN products p ON p.product_id = i.product_id
WHERE i.units_in_stock < i.reorder_level
ORDER BY units_short DESC, w.warehouse_name, p.product_name;

