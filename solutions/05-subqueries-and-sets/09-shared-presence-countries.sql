SELECT country
FROM customers
WHERE country IS NOT NULL

INTERSECT

SELECT country
FROM warehouses
ORDER BY country;

