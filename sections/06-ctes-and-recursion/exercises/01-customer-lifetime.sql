-- Build a completed-order lifetime summary for every customer, including customers with no orders.
-- First calculate one row per completed order in a CTE; aggregate that result by customer.
-- Columns: customer_id, company_name, completed_orders, lifetime_revenue, first_order, last_order
-- Revenue is rounded to 2 decimals and zero for customers with no completed orders.
-- Sort by lifetime_revenue descending, then customer_id.

-- TODO
SELECT customer_id, company_name, 0::bigint AS completed_orders,
       0::numeric AS lifetime_revenue, NULL::date AS first_order, NULL::date AS last_order
FROM customers
WHERE false;

