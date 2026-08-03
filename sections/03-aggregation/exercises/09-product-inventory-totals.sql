-- Write the query defined in this section's README.
SELECT product_id, product_name, 0::bigint AS total_stock,
       0::bigint AS stocked_warehouses, 0::bigint AS below_reorder_locations
FROM products
WHERE false;

