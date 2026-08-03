SELECT training.assert_true(
    (SELECT status = 'completed'
        AND shipped_at = order_date + 3
     FROM orders WHERE order_id = 1022),
    'processing order 1022 became completed with a three-day shipment date'
);
SELECT training.assert_true(
    (SELECT status = 'completed' FROM orders WHERE order_id = 1023),
    'unrelated orders were not changed'
);

