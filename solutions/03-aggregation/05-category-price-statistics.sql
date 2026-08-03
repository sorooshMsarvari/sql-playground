SELECT c.category_name,
       count(p.product_id) AS active_products,
       min(p.unit_price) AS min_price,
       max(p.unit_price) AS max_price,
       round(avg(p.unit_price), 2) AS average_price
FROM categories c
LEFT JOIN products p
       ON p.category_id = c.category_id
      AND p.discontinued = false
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;

