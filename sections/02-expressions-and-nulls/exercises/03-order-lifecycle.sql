-- Classify every order placed from 2024-04-01 through 2024-06-30.
-- Columns:
--   order_id
--   order_date
--   fulfillment_days: shipped_at - order_date (NULL if not shipped)
--   lifecycle: 'closed' for completed/refunded/cancelled, otherwise 'open'
-- Sort by order_date, then order_id.

-- TODO
SELECT 
  order_id,
  order_date,
  CASE
    WHEN shipped_at IS NULL THEN NULL
    ELSE shipped_at - order_date
  END AS fulfillment_days,
  CASE
    WHEN status IN ('completed', 'refunded', 'cancelled') THEN 'closed'
    ELSE 'open'
  END AS lifecycle
FROM orders
WHERE order_date >= DATE '2024-04-01'
  AND order_date < DATE '2024-07-01';

