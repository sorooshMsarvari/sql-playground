SELECT training.assert_true(
    (SELECT units_in_stock = 9 FROM inventory WHERE warehouse_id = 1 AND product_id = 2),
    'Berlin stock decreased by 3'
);
SELECT training.assert_true(
    (SELECT units_in_stock = 31 FROM inventory WHERE warehouse_id = 2 AND product_id = 2),
    'Paris stock increased by 3'
);
SELECT training.assert_true(
    (SELECT sum(units_in_stock) = 40 FROM inventory WHERE product_id = 2 AND warehouse_id IN (1, 2)),
    'the transfer preserved total stock'
);

