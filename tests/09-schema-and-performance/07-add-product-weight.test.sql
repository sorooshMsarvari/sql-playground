SELECT training.assert_true(
    EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'shop'
          AND table_name = 'products'
          AND column_name = 'weight_grams'
          AND data_type = 'integer'
          AND is_nullable = 'YES'
    ),
    'nullable integer weight_grams column exists'
);

UPDATE shop.products SET weight_grams = 500 WHERE product_id = 1;
SELECT training.assert_true(
    (SELECT weight_grams = 500 FROM shop.products WHERE product_id = 1),
    'positive product weights are accepted'
);

DO $$
BEGIN
    BEGIN
        UPDATE shop.products SET weight_grams = -1 WHERE product_id = 1;
        RAISE EXCEPTION 'weight constraint accepted a negative value';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
END
$$;

