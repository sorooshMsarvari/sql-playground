SELECT order_id,
       coalesce(to_char(shipped_at, 'YYYY-MM-DD'), 'not shipped') AS shipped_on,
       CASE WHEN shipped_at IS NULL THEN 'waiting' ELSE 'shipped' END AS shipping_state
FROM orders
ORDER BY order_id;

