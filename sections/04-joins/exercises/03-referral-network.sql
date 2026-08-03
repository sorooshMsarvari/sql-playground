-- List every customer and its referring company, if one exists.
-- Columns: customer_id, company_name, referred_by_company
-- Use NULL (not a label) when there is no referrer. Sort by customer_id.

-- TODO
SELECT c.customer_id, c.company_name, NULL::text AS referred_by_company
FROM customers c
WHERE false;

