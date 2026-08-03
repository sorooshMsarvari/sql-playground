SELECT c.category_name,
       p.product_name,
       p.unit_price,
       round((percent_rank() OVER (
           PARTITION BY p.category_id
           ORDER BY p.unit_price
       ) * 100)::numeric, 2) AS price_percent_rank
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.discontinued = false
ORDER BY c.category_name, p.unit_price, p.product_name;

