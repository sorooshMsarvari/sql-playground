CREATE INDEX idx_customers_lower_email
ON shop.customers (lower(email))
WHERE email IS NOT NULL;

