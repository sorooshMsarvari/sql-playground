SELECT c.category_name,
       jsonb_agg(
           jsonb_build_object(
               'product_id', p.product_id,
               'name', p.product_name,
               'price', p.unit_price
           ) ORDER BY p.product_name, p.product_id
       ) AS products
FROM categories c
JOIN products p ON p.category_id = c.category_id
WHERE p.discontinued = false
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;

