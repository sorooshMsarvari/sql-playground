-- Summarize every completed order.
-- Columns:
--   order_id
--   revenue: discounted line revenue rounded to 2 decimals
--   units: total quantity, not number of line items
-- Sort by revenue descending, then order_id ascending.

-- TODO
SELECT order_id, 0::numeric AS revenue, 0::bigint AS units
FROM orders
WHERE false
GROUP BY order_id;

