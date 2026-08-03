-- Starting with employee 1, recursively walk the management tree.
-- Columns:
--   employee_id
--   employee_name: "first_name last_name"
--   depth: root is 0, direct reports are 1, and so on
--   reporting_path: names joined with ' > ', from root to current employee
-- Sort by reporting_path.

-- TODO: use WITH RECURSIVE.
SELECT employee_id, first_name || ' ' || last_name AS employee_name,
       0 AS depth, ''::text AS reporting_path
FROM employees
WHERE false;

