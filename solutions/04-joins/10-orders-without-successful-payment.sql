SELECT o.order_id,
       o.status,
       c.company_name
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN payments p
       ON p.order_id = o.order_id
      AND p.status = 'succeeded'
WHERE p.payment_id IS NULL
ORDER BY o.order_id;

