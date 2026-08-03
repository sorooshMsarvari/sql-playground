-- Write the query defined in this section's README.
SELECT category_name, product_id, product_name, unit_price, 0::bigint AS row_number
FROM products
WHERE false;

