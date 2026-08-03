-- Find customers acquired through the partner channel whose JSON priority is high.
-- Columns: customer_id, company_name, channel, priority
-- Extract channel and priority as text. Sort by customer_id.

-- TODO
SELECT customer_id, company_name, ''::text AS channel, ''::text AS priority
FROM customers
WHERE false;

