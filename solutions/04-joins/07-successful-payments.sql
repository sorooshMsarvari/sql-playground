SELECT p.payment_id,
       o.order_id,
       c.company_name,
       p.amount,
       p.method
FROM payments p
JOIN orders o ON o.order_id = p.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE p.status = 'succeeded'
ORDER BY p.paid_at, p.payment_id;

