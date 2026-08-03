-- Write the query defined in this section's README.
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  upper(left(first_name, 1) || left(last_name, 1)) AS initials,
  lower(first_name|| '.' || last_name) AS username
FROM employees
ORDER BY employee_id;

