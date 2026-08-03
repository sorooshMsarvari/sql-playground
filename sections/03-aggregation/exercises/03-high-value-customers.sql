-- Find customers whose completed-order revenue is greater than 1500.
-- Columns: customer_id, company_name, completed_revenue (rounded to 2 decimals)
-- Sort by completed_revenue descending, then customer_id.

-- TODO
SELECT c.customer_id, c.company_name, 0::numeric AS completed_revenue
FROM customers c
WHERE false
GROUP BY c.customer_id, c.company_name;

