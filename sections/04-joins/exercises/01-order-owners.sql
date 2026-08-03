-- List orders placed from 2024-03-01 through 2024-06-30 with their owner names.
-- Columns: order_id, order_date, company_name, sales_rep
-- sales_rep is "first_name last_name". Sort by order_date, order_id.

-- TODO
SELECT o.order_id, o.order_date, ''::text AS company_name, ''::text AS sales_rep
FROM orders o
WHERE false;

