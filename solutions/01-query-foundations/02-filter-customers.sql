SELECT customer_id, company_name, country
FROM customers
WHERE segment = 'smb'
  AND country IN ('FR', 'ES', 'NL', 'AT', 'FI')
  AND created_at < DATE '2024-01-01'
ORDER BY country, company_name;

