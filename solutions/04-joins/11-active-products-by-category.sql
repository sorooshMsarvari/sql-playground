SELECT c.category_name,
       p.product_id,
       p.product_name
FROM categories c
LEFT JOIN products p
       ON p.category_id = c.category_id
      AND p.discontinued = false
ORDER BY c.category_name, p.product_name, p.product_id;

