-- Write the query defined in this section's README.
SELECT warehouse_name, product_name, units_in_stock, reorder_level,
       0::integer AS units_short
FROM inventory
WHERE false;

