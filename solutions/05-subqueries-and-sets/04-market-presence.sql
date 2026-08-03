SELECT country, 'customer'::text AS presence_type
FROM customers
WHERE country IS NOT NULL

UNION

SELECT country, 'warehouse'::text AS presence_type
FROM warehouses
ORDER BY country, presence_type;

