SELECT customer_id,
       company_name,
       lower(split_part(email, '@', 2)) AS email_domain
FROM customers
WHERE email IS NOT NULL
ORDER BY email_domain, customer_id;

