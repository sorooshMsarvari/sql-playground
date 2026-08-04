-- Summarize every completed order.
-- Columns:
--   order_id
--   revenue: discounted line revenue rounded to 2 decimals
--   units: total quantity, not number of line items
-- Sort by revenue descending, then order_id ascending.

-- TODO
SELECT
  o.order_id,
  round(
    sum(
      oi.quantity * oi.unit_price * (1 - oi.discount)
      ),
      2
  ) AS revenue,
  sum(oi.quantity) AS units
FROM orders AS o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY o.order_id
ORDER BY revenue DESC, order_id;