INSERT INTO products
    (sku, product_name, category_id, unit_price, discontinued, attributes, created_at)
VALUES
    ('OFF-FOOT', 'Ergonomic Footrest',
     (SELECT category_id FROM categories WHERE category_name = 'Office'),
     69.00, false, '{"color":"black","adjustable":true}'::jsonb, DATE '2025-03-15');

