-- Write the query defined in this section's README.
SELECT order_id, 0::numeric AS card_total, 0::numeric AS bank_transfer_total,
       0::numeric AS paypal_total
FROM payments
WHERE false;

