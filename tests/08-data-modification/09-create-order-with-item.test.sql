SELECT training.assert_true(
    (SELECT count(*) = 1
     FROM orders o
     JOIN order_items oi USING (order_id)
     WHERE o.order_id > 1024
       AND o.customer_id = 13
       AND o.sales_rep_id = 4
       AND o.order_date = DATE '2025-03-12'
       AND o.status = 'pending'
       AND o.shipping_country = 'CH'
       AND o.shipped_at IS NULL
       AND o.notes = 'Starter order'
       AND oi.product_id = 16
       AND oi.quantity = 2
       AND oi.unit_price = 29.00
       AND oi.discount = 0),
    'data-changing CTE created one generated order and its exact item row'
);

