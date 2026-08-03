SELECT sku, product_name, unit_price
FROM products
WHERE discontinued = false
ORDER BY unit_price DESC, sku
LIMIT 5;

