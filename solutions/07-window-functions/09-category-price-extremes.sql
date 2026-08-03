SELECT c.category_name,
       p.product_name,
       p.unit_price,
       first_value(p.product_name) OVER (
           PARTITION BY p.category_id
           ORDER BY p.unit_price DESC, p.product_id
       ) AS most_expensive_product,
       last_value(p.product_name) OVER (
           PARTITION BY p.category_id
           ORDER BY p.unit_price DESC, p.product_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS least_expensive_product
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.discontinued = false
ORDER BY c.category_name, p.unit_price DESC, p.product_id;

