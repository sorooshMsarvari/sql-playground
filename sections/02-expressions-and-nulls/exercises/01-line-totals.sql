-- Calculate each line total for orders 1001 through 1004 (inclusive).
-- Formula: quantity * unit_price * (1 - discount)
-- Columns: order_id, product_id, quantity, line_total
-- Round line_total to 2 decimal places. Sort by order_id, product_id.

-- TODO
SELECT  order_id,
        product_id,
        quantity,
        round(quantity * unit_price * (1-discount), 2) AS line_total
FROM order_items
WHERE order_id IN (1001, 1002, 1003, 1004)
ORDER BY order_id, product_id;
