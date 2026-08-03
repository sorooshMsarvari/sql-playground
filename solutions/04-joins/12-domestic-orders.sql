SELECT o.order_id,
       c.company_name,
       c.country AS customer_country,
       o.shipping_country
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE c.country IS NOT NULL
  AND c.country = o.shipping_country
ORDER BY o.order_id;

