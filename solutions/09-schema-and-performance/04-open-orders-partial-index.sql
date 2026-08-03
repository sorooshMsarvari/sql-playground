CREATE INDEX idx_orders_open_date
ON shop.orders (order_date, customer_id)
WHERE status IN ('pending', 'processing');

