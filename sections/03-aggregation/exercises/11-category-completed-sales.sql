-- Write the query defined in this section's README.
SELECT category_id, category_name, 0::bigint AS completed_units,
       0::numeric AS completed_revenue
FROM categories
WHERE false;

