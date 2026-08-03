SELECT product_id AS catalog_id,
       product_name AS name,
       unit_price AS price
FROM products
WHERE discontinued = false
  AND created_at >= DATE '2023-01-01'
ORDER BY created_at DESC, product_id;

