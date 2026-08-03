-- Write the query defined in this section's README.
SELECT segment, 0::bigint AS completed_orders, 0::numeric AS average_order_value,
       0::numeric AS total_revenue
FROM customers
WHERE false;

