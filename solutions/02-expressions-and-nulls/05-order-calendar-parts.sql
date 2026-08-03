SELECT order_id,
       extract(year FROM order_date)::integer AS order_year,
       extract(month FROM order_date)::integer AS order_month,
       extract(quarter FROM order_date)::integer AS order_quarter
FROM orders
WHERE order_date >= DATE '2024-01-01'
  AND order_date < DATE '2025-01-01'
ORDER BY order_date, order_id;

