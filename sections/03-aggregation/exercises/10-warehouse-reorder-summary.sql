-- Write the query defined in this section's README.
SELECT warehouse_id, warehouse_name, 0::bigint AS low_skus,
       0::bigint AS units_short
FROM warehouses
WHERE false;

