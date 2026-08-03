SELECT w.warehouse_id,
       w.warehouse_name,
       count(*) FILTER (WHERE i.units_in_stock < i.reorder_level) AS low_skus,
       sum(greatest(i.reorder_level - i.units_in_stock, 0)) AS units_short
FROM warehouses w
JOIN inventory i ON i.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_id, w.warehouse_name
HAVING count(*) FILTER (WHERE i.units_in_stock < i.reorder_level) > 0
ORDER BY units_short DESC, w.warehouse_id;

