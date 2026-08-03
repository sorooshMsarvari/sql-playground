SELECT order_id,
       round(coalesce(sum(amount) FILTER (WHERE method = 'card'), 0), 2) AS card_total,
       round(coalesce(sum(amount) FILTER (WHERE method = 'bank_transfer'), 0), 2) AS bank_transfer_total,
       round(coalesce(sum(amount) FILTER (WHERE method = 'paypal'), 0), 2) AS paypal_total
FROM payments
WHERE status = 'succeeded'
GROUP BY order_id
ORDER BY order_id;

