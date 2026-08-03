SELECT c.customer_id,
       c.company_name,
       referrer.company_name AS referred_by_company
FROM customers c
LEFT JOIN customers referrer ON referrer.customer_id = c.referred_by
ORDER BY c.customer_id;

