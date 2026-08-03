SELECT training.assert_true(
    EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE schemaname = 'shop'
          AND tablename = 'customers'
          AND indexname = 'idx_customers_lower_email'
          AND indexdef LIKE '%lower(email)%'
          AND indexdef LIKE '%email IS NOT NULL%'
    ),
    'partial expression index normalizes non-NULL email values'
);

