DELETE FROM payments
WHERE status = 'failed'
  AND paid_at < DATE '2025-01-01';

