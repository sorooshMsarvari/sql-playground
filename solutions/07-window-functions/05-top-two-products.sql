WITH ranked AS (
    SELECT c.category_name,
           p.product_id,
           p.product_name,
           p.unit_price,
           row_number() OVER (
               PARTITION BY p.category_id
               ORDER BY p.unit_price DESC, p.product_id
           ) AS row_number
    FROM products p
    JOIN categories c ON c.category_id = p.category_id
    WHERE p.discontinued = false
)
SELECT category_name, product_id, product_name, unit_price, row_number
FROM ranked
WHERE row_number <= 2
ORDER BY category_name, row_number;

