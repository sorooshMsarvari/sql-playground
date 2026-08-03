SELECT product_id, product_name, unit_price
FROM products
WHERE discontinued = false
  AND product_name ILIKE '%a%'
  AND unit_price BETWEEN 20 AND 150
ORDER BY product_name, product_id;

