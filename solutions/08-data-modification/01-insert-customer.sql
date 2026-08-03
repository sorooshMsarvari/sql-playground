INSERT INTO customers
    (company_name, email, phone, country, segment, referred_by, created_at, metadata)
VALUES
    ('Pioneer SpA', 'hello@pioneer.example', NULL, 'IT', 'midmarket', 5,
     DATE '2025-03-10', '{"channel":"event","priority":"high"}'::jsonb);

