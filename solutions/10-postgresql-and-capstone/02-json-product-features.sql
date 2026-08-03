SELECT product_name,
       (attributes ->> 'warranty_years')::integer AS warranty_years
FROM products
WHERE discontinued = false
  AND attributes @> '{"wireless":true}'::jsonb
ORDER BY warranty_years DESC, product_name;

