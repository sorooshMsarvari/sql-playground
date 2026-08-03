SELECT training.assert_true(
    (SELECT count(*) = 1
     FROM customers
     WHERE company_name = 'Pioneer SpA'
       AND email = 'hello@pioneer.example'
       AND phone IS NULL
       AND country = 'IT'
       AND segment = 'midmarket'
       AND referred_by = 5
       AND created_at = DATE '2025-03-10'
       AND metadata = '{"channel":"event","priority":"high"}'::jsonb
       AND customer_id > 14),
    'customer was inserted with a generated identity and exact values'
);

