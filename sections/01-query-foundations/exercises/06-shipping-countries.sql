-- Write the query defined in this section's README.
SELECT DISTINCT shipping_country AS country
FROM orders
WHERE status = 'completed'
ORDER BY country;

