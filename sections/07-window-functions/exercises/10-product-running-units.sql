-- Write the query defined in this section's README.
SELECT product_id, order_id, order_date, quantity, 0::bigint AS cumulative_units
FROM order_items
WHERE false;

