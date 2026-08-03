SELECT o.order_id,
       o.order_date,
       c.company_name,
       e.first_name || ' ' || e.last_name AS sales_rep
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN employees e ON e.employee_id = o.sales_rep_id
WHERE o.order_date >= DATE '2024-03-01'
  AND o.order_date < DATE '2024-07-01'
ORDER BY o.order_date, o.order_id;

