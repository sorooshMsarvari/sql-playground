-- Write the query defined in this section's README.
SELECT customer_id, company_name, NULL::integer AS latest_order_id,
       NULL::date AS latest_order_date, NULL::text AS latest_order_status
FROM customers
WHERE false;

