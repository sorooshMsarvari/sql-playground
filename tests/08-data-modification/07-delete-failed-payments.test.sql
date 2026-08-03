SELECT training.assert_true(
    (SELECT count(*) = 0 FROM payments WHERE status = 'failed' AND paid_at < DATE '2025-01-01'),
    'all qualifying failed payment rows were deleted'
);
SELECT training.assert_true(
    (SELECT count(*) = 23 FROM payments),
    'exactly one payment was deleted'
);
SELECT training.assert_true(
    EXISTS (SELECT 1 FROM orders WHERE order_id = 1005),
    'deleting a payment did not delete its order'
);

