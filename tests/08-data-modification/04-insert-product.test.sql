SELECT training.assert_true(
    (SELECT count(*) = 1
     FROM products p
     JOIN categories c USING (category_id)
     WHERE p.sku = 'OFF-FOOT'
       AND p.product_name = 'Ergonomic Footrest'
       AND c.category_name = 'Office'
       AND p.unit_price = 69.00
       AND p.discontinued = false
       AND p.attributes = '{"color":"black","adjustable":true}'::jsonb
       AND p.created_at = DATE '2025-03-15'
       AND p.product_id > 16),
    'product was inserted with generated identity and exact catalog values'
);

