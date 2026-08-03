\set ON_ERROR_STOP on
SET search_path TO shop, public;

INSERT INTO customers
    (customer_id, company_name, email, phone, country, segment, referred_by, created_at, metadata)
VALUES
    (1,  'Acme GmbH',       'hello@acme.example',     '+49-30-1001', 'DE', 'enterprise', NULL, '2022-01-10', '{"channel":"partner","priority":"high"}'),
    (2,  'Bluebird SAS',    'team@bluebird.example',  NULL,          'FR', 'smb',        1,    '2022-02-15', '{"channel":"organic","priority":"medium"}'),
    (3,  'Cedar Ltd',       'ops@cedar.example',      '+44-20-1003', 'GB', 'midmarket',  NULL, '2022-03-03', '{"channel":"outbound","priority":"medium"}'),
    (4,  'Delta SL',        'hola@delta.example',     NULL,          'ES', 'smb',        1,    '2022-05-20', '{"channel":"partner","priority":"low"}'),
    (5,  'Ember SRL',       'ciao@ember.example',     '+39-06-1005', 'IT', 'midmarket',  2,    '2022-06-11', '{"channel":"organic","priority":"high"}'),
    (6,  'Fjord AS',        'hei@fjord.example',      '+47-22-1006', 'NO', 'enterprise', NULL, '2022-07-30', '{"channel":"event","priority":"high"}'),
    (7,  'Grove BV',        'team@grove.example',     NULL,          'NL', 'smb',        3,    '2022-09-09', '{"channel":"partner","priority":"low"}'),
    (8,  'Harbor LDA',      'ola@harbor.example',     '+351-21-1008','PT', 'midmarket',  NULL, '2023-01-14', '{"channel":"organic","priority":"medium"}'),
    (9,  'Indigo PLC',      'hello@indigo.example',   '+353-1-1009', 'IE', 'enterprise', 6,    '2023-03-22', '{"channel":"outbound","priority":"high"}'),
    (10, 'Juniper GmbH',    'servus@juniper.example', NULL,          'AT', 'smb',        NULL, '2023-06-02', '{"channel":"event","priority":"low"}'),
    (11, 'Kestrel SRO',     'ahoj@kestrel.example',   '+420-2-1011', 'CZ', 'midmarket',  3,    '2024-01-19', '{"channel":"organic","priority":"medium"}'),
    (12, 'Luna Oy',         'moi@luna.example',       '+358-9-1012', 'FI', 'smb',        6,    '2024-04-27', '{"channel":"partner","priority":"medium"}'),
    (13, 'Meridian AG',     'team@meridian.example',  '+41-44-1013', 'CH', 'enterprise', 1,    '2024-06-15', '{"channel":"partner","priority":"high"}'),
    (14, 'Nomad Labs',      NULL,                     NULL,          NULL, 'smb',        NULL, '2024-08-08', '{"channel":"unknown"}');

INSERT INTO categories (category_id, category_name) VALUES
    (1, 'Electronics'), (2, 'Office'), (3, 'Stationery'), (4, 'Accessories'),
    (5, 'Wellness');

INSERT INTO products
    (product_id, sku, product_name, category_id, unit_price, discontinued, attributes, created_at)
VALUES
    (1,  'OFF-STAND',  'Laptop Stand',                2,  49.90, false, '{"color":"silver","material":"aluminum"}', '2022-01-01'),
    (2,  'ELE-KEY',    'Mechanical Keyboard',         1, 119.00, false, '{"color":"black","wireless":false,"warranty_years":2}', '2022-01-01'),
    (3,  'ELE-MOUSE',  'Wireless Mouse',              1,  59.50, false, '{"color":"black","wireless":true,"warranty_years":2}', '2022-01-01'),
    (4,  'ELE-HUB',    'USB-C Hub',                   1,  89.00, false, '{"color":"gray","ports":8,"warranty_years":1}', '2022-02-10'),
    (5,  'OFF-ARM',    'Monitor Arm',                 2, 139.00, false, '{"color":"black","material":"steel"}', '2022-03-15'),
    (6,  'OFF-LAMP',   'Desk Lamp',                   2,  79.00, false, '{"color":"white","dimmable":true}', '2022-04-11'),
    (7,  'ELE-HEAD',   'Noise-Canceling Headphones',  1, 249.00, false, '{"color":"black","wireless":true,"warranty_years":3}', '2022-05-20'),
    (8,  'ELE-CAM',    'Webcam',                      1,  99.00, false, '{"color":"black","resolution":"4K","warranty_years":2}', '2022-07-07'),
    (9,  'STA-NOTE',   'Hardcover Notebook',          3,  12.50, false, '{"color":"blue","pages":192}', '2022-01-01'),
    (10, 'STA-PEN',    'Pen Set',                     3,  18.00, false, '{"color":"assorted","count":5}', '2022-01-01'),
    (11, 'ACC-BAG',    'Commuter Backpack',           4,  89.00, false, '{"color":"navy","capacity_liters":24}', '2022-08-01'),
    (12, 'ACC-CABLE',  'Cable Organizer',             4,  22.00, false, '{"color":"black","count":6}', '2022-09-15'),
    (13, 'OFF-DESK',   'Standing Desk',               2, 699.00, false, '{"color":"oak","electric":true}', '2023-01-20'),
    (14, 'ELE-TRAVEL', 'Travel Adapter',              1,  39.00, false, '{"color":"white","ports":4}', '2023-03-12'),
    (15, 'ELE-DOCK',   'Legacy Dock',                 1, 159.00, true,  '{"color":"black","warranty_years":1}', '2021-06-01'),
    (16, 'ACC-BOTTLE', 'Insulated Water Bottle',      4,  29.00, false, '{"color":"green","capacity_ml":750}', '2024-02-14'),
    (17, 'OFF-MAT',    'Desk Mat',                    2,  35.00, false, '{"color":"gray","material":"felt"}', '2024-05-01');

INSERT INTO employees
    (employee_id, first_name, last_name, manager_id, department, hire_date, salary)
VALUES
    (1, 'Ava',   'Schmidt', NULL, 'Executive',  '2018-02-01', 120000),
    (2, 'Ben',   'Martin',  1,    'Sales',      '2019-04-15',  82000),
    (3, 'Chloe', 'Wilson',  1,    'Sales',      '2019-07-01',  84000),
    (4, 'Diego', 'Garcia',  2,    'Sales',      '2021-01-11',  61000),
    (5, 'Elena', 'Rossi',   2,    'Sales',      '2021-05-03',  63000),
    (6, 'Farah', 'Hansen',  3,    'Sales',      '2022-02-14',  60500),
    (7, 'Gavin', 'Murphy',  3,    'Sales',      '2022-08-22',  59000),
    (8, 'Hana',  'Novak',   1,    'Operations', '2020-10-05',  70000);

INSERT INTO orders
    (order_id, customer_id, sales_rep_id, order_date, status, shipping_country, shipped_at, notes)
VALUES
    (1001, 1,  4, '2024-01-05', 'completed',  'DE', '2024-01-07', NULL),
    (1002, 2,  5, '2024-01-08', 'completed',  'FR', '2024-01-10', 'Leave at reception'),
    (1003, 3,  6, '2024-01-20', 'cancelled',  'GB', NULL,         'Customer changed plans'),
    (1004, 1,  4, '2024-02-12', 'completed',  'DE', '2024-02-14', NULL),
    (1005, 4,  7, '2024-02-14', 'processing', 'ES', NULL,         'Backordered item'),
    (1006, 5,  5, '2024-03-01', 'completed',  'IT', '2024-03-04', NULL),
    (1007, 6,  6, '2024-03-18', 'completed',  'NO', '2024-03-20', NULL),
    (1008, 2,  5, '2024-04-02', 'completed',  'FR', '2024-04-05', NULL),
    (1009, 7,  7, '2024-04-15', 'refunded',   'NL', '2024-04-17', 'Damaged in transit'),
    (1010, 8,  4, '2024-05-06', 'completed',  'PT', '2024-05-08', NULL),
    (1011, 9,  6, '2024-06-11', 'completed',  'IE', '2024-06-14', 'Split payment'),
    (1012, 3,  7, '2024-06-30', 'completed',  'GB', '2024-07-02', NULL),
    (1013, 10, 4, '2024-07-04', 'pending',    'AT', NULL,         'Awaiting bank transfer'),
    (1014, 1,  5, '2024-07-22', 'completed',  'DE', '2024-07-24', NULL),
    (1015, 5,  6, '2024-08-09', 'completed',  'IT', '2024-08-11', NULL),
    (1016, 11, 7, '2024-09-17', 'completed',  'CZ', '2024-09-20', NULL),
    (1017, 6,  4, '2024-10-03', 'completed',  'NO', '2024-10-07', NULL),
    (1018, 2,  5, '2024-10-21', 'cancelled',  'FR', NULL,         NULL),
    (1019, 12, 6, '2024-11-15', 'completed',  'FI', '2024-11-18', NULL),
    (1020, 9,  7, '2024-12-02', 'completed',  'IE', '2024-12-05', NULL),
    (1021, 4,  4, '2025-01-10', 'completed',  'ES', '2025-01-13', NULL),
    (1022, 8,  5, '2025-02-05', 'processing', 'PT', NULL,         'Expedited shipping'),
    (1023, 11, 6, '2025-02-18', 'completed',  'CZ', '2025-02-21', NULL),
    (1024, 1,  7, '2025-03-01', 'completed',  'DE', '2025-03-04', NULL);

INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount) VALUES
    (1001, 2, 2, 119.00, 0.000), (1001, 3, 2, 59.50, 0.100), (1001, 12, 3, 22.00, 0.000),
    (1002, 1, 3, 49.90, 0.000), (1002, 6, 2, 79.00, 0.050),
    (1003, 13, 1, 699.00, 0.000), (1003, 5, 2, 139.00, 0.000),
    (1004, 13, 2, 679.00, 0.100), (1004, 5, 2, 139.00, 0.000),
    (1005, 7, 1, 249.00, 0.000), (1005, 15, 1, 159.00, 0.200),
    (1006, 8, 4, 99.00, 0.100), (1006, 4, 2, 89.00, 0.000),
    (1007, 13, 3, 699.00, 0.150), (1007, 2, 5, 119.00, 0.100),
    (1008, 9, 10, 12.50, 0.000), (1008, 10, 4, 18.00, 0.000), (1008, 12, 2, 22.00, 0.000),
    (1009, 11, 2, 89.00, 0.000), (1009, 14, 2, 39.00, 0.000),
    (1010, 6, 3, 79.00, 0.000), (1010, 1, 3, 49.90, 0.000),
    (1011, 7, 4, 239.00, 0.100), (1011, 8, 4, 99.00, 0.100), (1011, 3, 6, 59.50, 0.150),
    (1012, 4, 2, 89.00, 0.000), (1012, 14, 3, 39.00, 0.000),
    (1013, 13, 1, 699.00, 0.000),
    (1014, 5, 4, 139.00, 0.100), (1014, 1, 5, 49.90, 0.000),
    (1015, 2, 3, 119.00, 0.050), (1015, 3, 3, 59.50, 0.000),
    (1016, 11, 3, 89.00, 0.000), (1016, 9, 12, 12.50, 0.100),
    (1017, 7, 2, 249.00, 0.000), (1017, 4, 4, 89.00, 0.100),
    (1018, 15, 2, 149.00, 0.000),
    (1019, 14, 5, 39.00, 0.050), (1019, 12, 5, 22.00, 0.000),
    (1020, 13, 2, 699.00, 0.100), (1020, 6, 4, 79.00, 0.000),
    (1021, 8, 3, 99.00, 0.000), (1021, 4, 3, 89.00, 0.000),
    (1022, 13, 1, 699.00, 0.050), (1022, 5, 2, 139.00, 0.000),
    (1023, 2, 4, 119.00, 0.100), (1023, 3, 4, 59.50, 0.100), (1023, 12, 4, 22.00, 0.000),
    (1024, 7, 3, 249.00, 0.100), (1024, 11, 2, 89.00, 0.000);

INSERT INTO payments (payment_id, order_id, paid_at, amount, method, status) VALUES
    (1, 1001, '2024-01-05', 411.10, 'card',          'succeeded'),
    (2, 1002, '2024-01-08', 299.80, 'paypal',        'succeeded'),
    (3, 1003, '2024-01-20', 977.00, 'card',          'refunded'),
    (4, 1004, '2024-02-12',1499.20, 'bank_transfer', 'succeeded'),
    (5, 1005, '2024-02-14', 376.20, 'card',          'failed'),
    (6, 1006, '2024-03-01', 534.40, 'card',          'succeeded'),
    (7, 1007, '2024-03-18',2317.95, 'bank_transfer', 'succeeded'),
    (8, 1008, '2024-04-02', 241.00, 'card',          'succeeded'),
    (9, 1009, '2024-04-15', 256.00, 'paypal',        'refunded'),
    (10,1010, '2024-05-06', 386.70, 'card',          'succeeded'),
    (11,1011, '2024-06-11', 900.00, 'bank_transfer', 'succeeded'),
    (12,1011, '2024-06-12', 618.25, 'card',          'succeeded'),
    (13,1012, '2024-06-30', 295.00, 'paypal',        'succeeded'),
    (14,1013, '2024-07-04', 699.00, 'bank_transfer', 'pending'),
    (15,1014, '2024-07-22', 749.90, 'card',          'succeeded'),
    (16,1015, '2024-08-09', 517.65, 'card',          'succeeded'),
    (17,1016, '2024-09-17', 402.00, 'paypal',        'succeeded'),
    (18,1017, '2024-10-03', 818.40, 'bank_transfer', 'succeeded'),
    (19,1019, '2024-11-15', 295.25, 'card',          'succeeded'),
    (20,1020, '2024-12-02',1574.20, 'bank_transfer', 'succeeded'),
    (21,1021, '2025-01-10', 564.00, 'card',          'succeeded'),
    (22,1022, '2025-02-05', 942.05, 'card',          'pending'),
    (23,1023, '2025-02-18', 709.60, 'paypal',        'succeeded'),
    (24,1024, '2025-03-01', 850.30, 'card',          'succeeded');

INSERT INTO warehouses (warehouse_id, warehouse_name, country) VALUES
    (1, 'Berlin Central', 'DE'), (2, 'Paris West', 'FR'), (3, 'Dublin Hub', 'IE');

INSERT INTO inventory (warehouse_id, product_id, units_in_stock, reorder_level, last_stocked_at) VALUES
    (1,1, 45,15,'2025-02-01'), (1,2,12,20,'2025-01-15'), (1,3,30,20,'2025-02-10'),
    (1,4,  8,12,'2024-12-12'), (1,5,22,10,'2025-01-20'), (1,6, 4,10,'2024-11-30'),
    (1,7, 16,8,'2025-02-18'),  (1,8,21,10,'2025-01-08'), (1,9,90,30,'2025-02-20'),
    (1,10,70,25,'2025-02-20'),(1,11,14,10,'2025-01-29'),(1,12,50,20,'2025-02-14'),
    (1,13,3,5,'2024-12-01'),  (1,14,25,12,'2025-01-31'),(1,15,0,0,'2023-06-01'),
    (2,1, 20,10,'2025-01-20'),(2,2,28,15,'2025-02-03'), (2,3, 7,15,'2024-12-21'),
    (2,4, 18,10,'2025-01-13'),(2,5, 5,8,'2024-11-11'),  (2,6,19,10,'2025-02-08'),
    (2,7,  6,8,'2025-01-02'), (2,8,13,10,'2025-02-11'), (2,9,40,20,'2025-02-04'),
    (2,10,35,20,'2025-02-04'),(2,11,9,10,'2024-12-18'), (2,12,28,15,'2025-01-27'),
    (2,13, 7,4,'2025-02-01'), (2,14,4,10,'2024-10-10'), (2,16,30,10,'2025-02-19'),
    (3,1, 10,8,'2025-01-12'), (3,2, 9,12,'2024-12-05'), (3,3,24,12,'2025-02-15'),
    (3,4,  6,8,'2024-11-25'), (3,7,11,6,'2025-01-16'),  (3,8,5,8,'2024-12-30'),
    (3,11,20,8,'2025-02-06'),(3,12,17,10,'2025-01-18'),(3,13,1,3,'2024-10-20'),
    (3,14,14,8,'2025-02-09'),(3,16,16,8,'2025-02-12');

SELECT setval(pg_get_serial_sequence('customers','customer_id'), (SELECT max(customer_id) FROM customers));
SELECT setval(pg_get_serial_sequence('categories','category_id'), (SELECT max(category_id) FROM categories));
SELECT setval(pg_get_serial_sequence('products','product_id'), (SELECT max(product_id) FROM products));
SELECT setval(pg_get_serial_sequence('employees','employee_id'), (SELECT max(employee_id) FROM employees));
SELECT setval(pg_get_serial_sequence('orders','order_id'), (SELECT max(order_id) FROM orders));
SELECT setval(pg_get_serial_sequence('payments','payment_id'), (SELECT max(payment_id) FROM payments));
SELECT setval(pg_get_serial_sequence('warehouses','warehouse_id'), (SELECT max(warehouse_id) FROM warehouses));
