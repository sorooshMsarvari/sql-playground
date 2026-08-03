-- Reconcile completed orders whose successful payments do not equal their order total.
-- Compute order totals and payment totals independently to avoid multiplying rows.
-- Columns: order_id, order_total, paid_total, difference
-- Round all money columns to 2 decimals. difference = paid_total - order_total.
-- Sort by absolute difference descending, then order_id.

-- TODO
SELECT order_id, 0::numeric AS order_total, 0::numeric AS paid_total, 0::numeric AS difference
FROM orders
WHERE false;

