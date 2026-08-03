-- Rank active products by price within each category.
-- Equal prices should receive the same rank without gaps: use DENSE_RANK.
-- Columns: category_name, product_name, unit_price, price_rank
-- Sort by category_name, price_rank, product_name.

-- TODO
SELECT c.category_name, p.product_name, p.unit_price, 0::bigint AS price_rank
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE false;

