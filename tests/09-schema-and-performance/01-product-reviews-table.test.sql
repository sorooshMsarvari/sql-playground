INSERT INTO shop.product_reviews (product_id, rating, body)
VALUES (1, 5, 'Excellent stand');

SELECT training.assert_true(
    (SELECT count(*) = 1
     FROM shop.product_reviews
     WHERE product_id = 1 AND rating = 5 AND created_at IS NOT NULL),
    'valid reviews can be inserted and defaults are applied'
);

DO $$
BEGIN
    BEGIN
        INSERT INTO shop.product_reviews (product_id, rating) VALUES (1, 6);
        RAISE EXCEPTION 'rating constraint accepted an invalid value';
    EXCEPTION WHEN check_violation THEN
        NULL;
    END;
END
$$;

SELECT training.assert_true(
    EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conrelid = 'shop.product_reviews'::regclass
          AND contype = 'f'
          AND confdeltype = 'c'
    ),
    'product foreign key uses ON DELETE CASCADE'
);

