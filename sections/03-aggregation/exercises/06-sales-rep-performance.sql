-- Write the query defined in this section's README.
SELECT employee_id, ''::text AS sales_rep, 0::bigint AS completed_orders,
       0::numeric AS completed_revenue
FROM employees
WHERE false;

