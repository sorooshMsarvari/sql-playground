SELECT p.product_id,
       p.product_name,
       coalesce(sum(i.units_in_stock), 0) AS total_stock,
       count(i.warehouse_id) AS stocked_warehouses,
       count(i.warehouse_id) FILTER (WHERE i.units_in_stock < i.reorder_level) AS below_reorder_locations
FROM products p
LEFT JOIN inventory i ON i.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_stock DESC, p.product_id;

