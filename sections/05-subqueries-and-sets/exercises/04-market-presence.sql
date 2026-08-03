-- Build a unique list of countries and the kind of business presence in each.
-- Customer rows use presence_type = 'customer'; warehouse rows use 'warehouse'.
-- Exclude NULL customer countries and use UNION (not UNION ALL) to remove duplicates.
-- Columns: country, presence_type
-- Sort by country, then presence_type.

-- TODO
SELECT country, ''::text AS presence_type
FROM customers
WHERE false;

