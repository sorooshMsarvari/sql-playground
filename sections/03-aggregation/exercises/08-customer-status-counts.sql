-- Write the query defined in this section's README.
SELECT customer_id, company_name, 0::bigint AS total_orders,
       0::bigint AS completed_orders, 0::bigint AS open_orders
FROM customers
WHERE false;

