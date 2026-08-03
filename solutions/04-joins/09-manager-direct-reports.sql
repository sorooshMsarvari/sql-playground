SELECT manager.employee_id AS manager_id,
       manager.first_name || ' ' || manager.last_name AS manager_name,
       report.employee_id AS report_id,
       report.first_name || ' ' || report.last_name AS report_name
FROM employees manager
JOIN employees report ON report.manager_id = manager.employee_id
ORDER BY manager.employee_id, report.employee_id;

