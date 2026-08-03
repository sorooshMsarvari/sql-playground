SELECT customer_id,
       company_name,
       metadata ->> 'channel' AS channel,
       metadata ->> 'priority' AS priority
FROM customers
WHERE metadata ->> 'channel' = 'partner'
  AND metadata ->> 'priority' = 'high'
ORDER BY customer_id;

