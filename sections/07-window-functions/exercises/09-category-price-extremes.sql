-- Write the query defined in this section's README.
SELECT category_name, product_name, unit_price,
       ''::text AS most_expensive_product, ''::text AS least_expensive_product
FROM products
WHERE false;

