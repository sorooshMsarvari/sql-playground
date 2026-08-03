-- Produce a contact-quality report for every customer.
-- Columns:
--   customer_id
--   company_name
--   contact_email: email, or 'missing' when email is NULL
--   phone_status: 'available' when phone is present, otherwise 'missing'
-- Sort by customer_id.

-- TODO
SELECT customer_id, company_name, email AS contact_email, phone AS phone_status
FROM customers
WHERE false;

