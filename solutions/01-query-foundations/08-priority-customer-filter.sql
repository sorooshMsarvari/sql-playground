SELECT customer_id, company_name, segment, created_at
FROM customers
WHERE segment = 'enterprise'
   OR (segment = 'midmarket' AND created_at >= DATE '2023-01-01')
ORDER BY segment, customer_id;

