-- Count customers by country, placing NULL countries in an 'Unknown' bucket.
-- Columns: country, customer_count
-- Sort by customer_count descending, then country ascending.

-- TODO
SELECT
  COALESCE(country, 'Unknown') as country,
  count(*) as customer_count
FROM customers
WHERE true
GROUP BY country
ORDER BY customer_count DESC, country;
