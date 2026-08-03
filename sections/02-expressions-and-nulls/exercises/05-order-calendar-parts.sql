-- Write the query defined in this section's README.
SELECT order_id, 0::integer AS order_year, 0::integer AS order_month,
       0::integer AS order_quarter
FROM orders
WHERE false;

