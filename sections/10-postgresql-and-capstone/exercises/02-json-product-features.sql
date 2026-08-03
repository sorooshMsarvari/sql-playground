-- Find active products whose attributes say wireless is true.
-- Columns: product_name, warranty_years (as integer)
-- Sort by warranty_years descending, then product_name.

-- TODO
SELECT product_name, 0::integer AS warranty_years
FROM products
WHERE false;

