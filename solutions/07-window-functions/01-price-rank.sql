SELECT c.category_name,
       p.product_name,
       p.unit_price,
       dense_rank() OVER (
           PARTITION BY p.category_id
           ORDER BY p.unit_price DESC
       ) AS price_rank
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.discontinued = false
ORDER BY c.category_name, price_rank, p.product_name;

