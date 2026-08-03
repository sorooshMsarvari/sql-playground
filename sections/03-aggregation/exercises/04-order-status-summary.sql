-- Write the query defined in this section's README.
SELECT status, 0::bigint AS order_count, 0::numeric AS gross_revenue
FROM orders
WHERE false
GROUP BY status;

