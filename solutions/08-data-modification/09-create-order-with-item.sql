WITH new_order AS (
    INSERT INTO orders
        (customer_id, sales_rep_id, order_date, status, shipping_country, shipped_at, notes)
    VALUES
        (13, 4, DATE '2025-03-12', 'pending', 'CH', NULL, 'Starter order')
    RETURNING order_id
)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
SELECT order_id, 16, 2, 29.00, 0
FROM new_order;

