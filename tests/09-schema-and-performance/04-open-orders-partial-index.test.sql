SELECT training.assert_true(
    EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE schemaname = 'shop'
          AND tablename = 'orders'
          AND indexname = 'idx_orders_open_date'
          AND indexdef LIKE '%(order_date, customer_id)%'
          AND indexdef LIKE '%pending%'
          AND indexdef LIKE '%processing%'
    ),
    'partial index has the requested keys and both open-status predicates'
);

