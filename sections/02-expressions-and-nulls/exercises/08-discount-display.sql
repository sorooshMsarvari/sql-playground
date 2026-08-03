-- Write the query defined in this section's README.
SELECT 
  order_id,
  product_id,
  round(discount * 100, 1) AS discount_percent,
  round(unit_price * (1 - discount),2) AS net_unit_price
FROM order_items
WHERE discount > 0
ORDER BY order_id, product_id;

