-- Write the query defined in this section's README.
SELECT
  product_id,
  product_name,
  CASE
    WHEN unit_price < 50 THEN 'budget'
    WHEN unit_price >= 50 AND unit_price < 150 THEN 'standard'
    ELSE 'premium'
  END AS price_band
FROM products
WHERE discontinued = false
ORDER BY unit_price, product_id;

