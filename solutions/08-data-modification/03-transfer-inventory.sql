UPDATE inventory
SET units_in_stock = units_in_stock - 3
WHERE warehouse_id = 1 AND product_id = 2;

UPDATE inventory
SET units_in_stock = units_in_stock + 3
WHERE warehouse_id = 2 AND product_id = 2;

