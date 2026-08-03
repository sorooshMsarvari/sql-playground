-- Produce one row for every month in calendar year 2024, including months with no completed orders.
-- Columns: month_start (date), completed_orders, revenue (rounded to 2 decimals)
-- Use generate_series, LEFT JOIN orders/items, and sort by month_start.

-- TODO
SELECT DATE '2024-01-01' AS month_start, 0::bigint AS completed_orders, 0::numeric AS revenue
WHERE false;

