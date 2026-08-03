SELECT training.assert_true(
    (SELECT email = 'contact@nomad.example'
        AND country = 'SE'
        AND company_name = 'Nomad Labs'
        AND segment = 'smb'
     FROM customers WHERE customer_id = 14),
    'Nomad Labs contact fields were repaired without changing identity fields'
);
SELECT training.assert_true(
    (SELECT email = 'team@meridian.example' FROM customers WHERE customer_id = 13),
    'other customers were unchanged'
);

