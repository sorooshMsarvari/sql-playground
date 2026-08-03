UPDATE orders
SET status = 'completed',
    shipped_at = order_date + 3
WHERE order_id = 1022
  AND status = 'processing';

