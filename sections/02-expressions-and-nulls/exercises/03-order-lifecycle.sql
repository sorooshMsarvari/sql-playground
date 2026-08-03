-- Classify every order placed from 2024-04-01 through 2024-06-30.
-- Columns:
--   order_id
--   order_date
--   fulfillment_days: shipped_at - order_date (NULL if not shipped)
--   lifecycle: 'closed' for completed/refunded/cancelled, otherwise 'open'
-- Sort by order_date, then order_id.

-- TODO
SELECT order_id, order_date, NULL::integer AS fulfillment_days, ''::text AS lifecycle
FROM orders
WHERE false;

