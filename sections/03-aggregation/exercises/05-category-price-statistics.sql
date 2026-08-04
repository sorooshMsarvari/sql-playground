-- Write the query defined in this section's README.
SELECT p.category_id, count(*)
FROM products p
GROUP BY p.category_id