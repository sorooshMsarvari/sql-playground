-- Write the query defined in this section's README.
SELECT product_id, product_name, 0::bigint AS total_stock,
       0::bigint AS total_reorder_level, ''::text AS stock_state
FROM products
WHERE false;

