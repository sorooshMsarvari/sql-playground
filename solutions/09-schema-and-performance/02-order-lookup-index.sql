CREATE INDEX idx_orders_customer_date
ON shop.orders (customer_id, order_date DESC)
INCLUDE (status);

