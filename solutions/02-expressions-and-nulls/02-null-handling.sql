SELECT customer_id,
       company_name,
       coalesce(email, 'missing') AS contact_email,
       CASE WHEN phone IS NULL THEN 'missing' ELSE 'available' END AS phone_status
FROM customers
ORDER BY customer_id;

