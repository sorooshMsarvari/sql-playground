-- Report completed-order sales for every product, including products never sold.
-- Columns: product_id, product_name, sold_units
-- sold_units must be 0, not NULL, when there are no completed sales.
-- Sort by sold_units descending, then product_name ascending.

-- TODO
SELECT p.product_id, p.product_name, 0::bigint AS sold_units
FROM products p
WHERE false;

