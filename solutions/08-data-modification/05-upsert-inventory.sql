INSERT INTO inventory
    (warehouse_id, product_id, units_in_stock, reorder_level, last_stocked_at)
VALUES
    (1, 1, 5, 15, DATE '2025-03-20')
ON CONFLICT (warehouse_id, product_id)
DO UPDATE
SET units_in_stock = inventory.units_in_stock + excluded.units_in_stock,
    last_stocked_at = excluded.last_stocked_at;

