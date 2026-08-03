WITH inventory_metrics AS (
    SELECT w.warehouse_name,
           c.category_name,
           p.product_id,
           p.product_name,
           coalesce(p.attributes ->> 'color', 'unknown') AS product_color,
           i.units_in_stock,
           i.reorder_level,
           sum(i.units_in_stock) OVER (PARTITION BY p.product_id) AS product_total_stock
    FROM inventory i
    JOIN warehouses w ON w.warehouse_id = i.warehouse_id
    JOIN products p ON p.product_id = i.product_id
    JOIN categories c ON c.category_id = p.category_id
    WHERE p.discontinued = false
)
SELECT warehouse_name,
       category_name,
       product_name,
       product_color,
       units_in_stock,
       reorder_level,
       reorder_level - units_in_stock AS units_short,
       product_total_stock
FROM inventory_metrics
WHERE units_in_stock < reorder_level
ORDER BY units_short DESC, warehouse_name, product_name;

