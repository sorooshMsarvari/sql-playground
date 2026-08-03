-- Write the query defined in this section's README.
SELECT customer_id, company_name, 0::bigint AS order_count,
       NULL::date AS first_order, NULL::date AS last_order
FROM customers
WHERE false;

