SELECT order_id,
       product_id,
       quantity,
       round(quantity * unit_price * (1 - discount), 2) AS line_total
FROM order_items
WHERE order_id BETWEEN 1001 AND 1004
ORDER BY order_id, product_id;

