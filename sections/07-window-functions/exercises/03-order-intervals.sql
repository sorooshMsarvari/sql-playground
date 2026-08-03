-- Show the completed-order timeline for each customer.
-- Columns: customer_id, order_id, order_date, previous_order_date, days_since_previous
-- The first completed order per customer has NULL for both previous columns.
-- Sort by customer_id, order_date, order_id.

-- TODO
SELECT customer_id, order_id, order_date, NULL::date AS previous_order_date,
       NULL::integer AS days_since_previous
FROM orders
WHERE false;

