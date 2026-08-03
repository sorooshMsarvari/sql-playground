-- Write the query defined in this section's README.
SELECT warehouse_name, category_name, product_name, ''::text AS product_color,
       units_in_stock, reorder_level, 0::integer AS units_short,
       0::bigint AS product_total_stock
FROM inventory
WHERE false;

