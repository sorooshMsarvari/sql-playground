-- Write the query defined in this section's README.
SELECT product_id, product_name, unit_price
FROM products
WHERE discontinued = false
  AND unit_price <= 150
  AND unit_price >= 20
  AND product_name ILIKE '%a%'
ORDER BY product_name, product_id;
