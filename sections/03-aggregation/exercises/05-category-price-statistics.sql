-- Write the query defined in this section's README.
SELECT category_name, 0::bigint AS active_products, NULL::numeric AS min_price,
       NULL::numeric AS max_price, NULL::numeric AS average_price
FROM categories
WHERE false
GROUP BY category_name;

