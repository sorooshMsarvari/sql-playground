UPDATE products
SET unit_price = round(unit_price * 1.05, 2)
WHERE discontinued = false
  AND category_id = (
      SELECT category_id FROM categories WHERE category_name = 'Stationery'
  );

