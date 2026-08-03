WITH RECURSIVE organization AS (
    SELECT e.employee_id,
           e.first_name || ' ' || e.last_name AS employee_name,
           0 AS depth,
           (e.first_name || ' ' || e.last_name)::text AS reporting_path
    FROM employees e
    WHERE e.employee_id = 1

    UNION ALL

    SELECT child.employee_id,
           child.first_name || ' ' || child.last_name,
           parent.depth + 1,
           parent.reporting_path || ' > ' || child.first_name || ' ' || child.last_name
    FROM employees child
    JOIN organization parent ON parent.employee_id = child.manager_id
)
SELECT employee_id, employee_name, depth, reporting_path
FROM organization
ORDER BY reporting_path;

