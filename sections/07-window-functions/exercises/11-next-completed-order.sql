-- Write the query defined in this section's README.
SELECT customer_id, order_id, order_date, NULL::date AS next_order_date,
       NULL::integer AS days_until_next
FROM orders
WHERE false;

