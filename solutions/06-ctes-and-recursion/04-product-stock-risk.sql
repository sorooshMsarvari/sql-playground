WITH stock_totals AS (
    SELECT p.product_id,
           p.product_name,
           coalesce(sum(i.units_in_stock), 0) AS total_stock,
           coalesce(sum(i.reorder_level), 0) AS total_reorder_level
    FROM products p
    LEFT JOIN inventory i ON i.product_id = p.product_id
    WHERE p.discontinued = false
    GROUP BY p.product_id, p.product_name
), classified AS (
    SELECT *,
           CASE
               WHEN total_stock < total_reorder_level THEN 'at risk'
               ELSE 'sufficient'
           END AS stock_state
    FROM stock_totals
)
SELECT product_id, product_name, total_stock, total_reorder_level, stock_state
FROM classified
ORDER BY stock_state, product_id;

