-- Write the query defined in this section's README.
SELECT customer_id, company_name, 0 AS depth, ''::text AS referral_path
FROM customers
WHERE false;

