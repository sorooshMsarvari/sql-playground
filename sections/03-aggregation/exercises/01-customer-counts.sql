-- Count customers by country, placing NULL countries in an 'Unknown' bucket.
-- Columns: country, customer_count
-- Sort by customer_count descending, then country ascending.

-- TODO
SELECT country, 0::bigint AS customer_count
FROM customers
WHERE false
GROUP BY country;

