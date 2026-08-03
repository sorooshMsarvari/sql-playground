SELECT training.assert_true(
    (SELECT units_in_stock = 50
        AND reorder_level = 15
        AND last_stocked_at = DATE '2025-03-20'
     FROM inventory
     WHERE warehouse_id = 1 AND product_id = 1),
    'conflict branch added five units and updated the stocking date'
);
SELECT training.assert_true(
    (SELECT count(*) = 1 FROM inventory WHERE warehouse_id = 1 AND product_id = 1),
    'upsert preserved one row for the composite key'
);

