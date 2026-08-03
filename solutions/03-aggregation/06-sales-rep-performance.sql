SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS sales_rep,
       count(DISTINCT o.order_id) AS completed_orders,
       round(coalesce(sum(oi.quantity * oi.unit_price * (1 - oi.discount)), 0), 2) AS completed_revenue
FROM employees e
LEFT JOIN orders o
       ON o.sales_rep_id = e.employee_id
      AND o.status = 'completed'
LEFT JOIN order_items oi ON oi.order_id = o.order_id
WHERE e.department = 'Sales'
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY completed_revenue DESC, e.employee_id;

