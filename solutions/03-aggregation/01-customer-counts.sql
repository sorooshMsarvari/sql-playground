SELECT coalesce(country, 'Unknown') AS country,
       count(*) AS customer_count
FROM customers
GROUP BY coalesce(country, 'Unknown')
ORDER BY customer_count DESC, country;

