SELECT training.assert_true(
    (SELECT count(*) = 2
     FROM products p
     JOIN categories c USING (category_id)
     WHERE c.category_name = 'Stationery'
       AND p.unit_price IN (13.13, 18.90)),
    'both active Stationery prices increased by 5% and were rounded'
);
SELECT training.assert_true(
    (SELECT unit_price = 49.90 FROM products WHERE product_id = 1),
    'products outside Stationery were unchanged'
);

