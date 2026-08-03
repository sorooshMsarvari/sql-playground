-- Write the query defined in this section's README.
SELECT order_id, product_id, 0::numeric AS discount_percent,
       0::numeric AS net_unit_price
FROM order_items
WHERE false;

