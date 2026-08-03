SELECT training.assert_true(
    EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE schemaname = 'shop'
          AND tablename = 'orders'
          AND indexname = 'idx_orders_customer_date'
          AND indexdef LIKE '%(customer_id, order_date DESC) INCLUDE (status)%'
    ),
    'covering index has the requested key order and included column'
);

