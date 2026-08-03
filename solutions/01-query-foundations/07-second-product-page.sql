SELECT product_id, sku, product_name
FROM products
WHERE discontinued = false
ORDER BY product_id
LIMIT 5 OFFSET 5;

