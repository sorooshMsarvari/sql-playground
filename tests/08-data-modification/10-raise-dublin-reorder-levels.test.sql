WITH expected(product_id, reorder_level) AS (
    VALUES (2, 14), (4, 10), (8, 10), (13, 5)
)
SELECT training.assert_true(
    NOT EXISTS (
        (SELECT i.product_id, i.reorder_level
         FROM inventory i
         WHERE i.warehouse_id = 3
           AND i.product_id IN (2, 4, 8, 13)
         EXCEPT ALL SELECT * FROM expected)
        UNION ALL
        (SELECT * FROM expected EXCEPT ALL
         SELECT i.product_id, i.reorder_level
         FROM inventory i
         WHERE i.warehouse_id = 3
           AND i.product_id IN (2, 4, 8, 13))
    ),
    'all four low-stock Dublin reorder levels increased by two'
);
SELECT training.assert_true(
    (SELECT reorder_level = 8 FROM inventory WHERE warehouse_id = 3 AND product_id = 1),
    'Dublin rows not below their threshold were unchanged'
);

