SELECT country
FROM customers
WHERE country IS NOT NULL

EXCEPT

SELECT country
FROM warehouses
ORDER BY country;

