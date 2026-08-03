-- For each month that had completed orders in 2024, calculate monthly and cumulative revenue.
-- Aggregate to months in a CTE before applying the window function.
-- Columns: month_start (date), monthly_revenue, running_revenue
-- Round money to 2 decimals. Sort by month_start.

-- TODO
SELECT DATE '2024-01-01' AS month_start, 0::numeric AS monthly_revenue,
       0::numeric AS running_revenue
WHERE false;

