-- Write the query defined in this section's README.
SELECT order_id,
  coalesce(nullif(btrim(notes), ''), 'none') AS note_text
FROM orders
ORDER BY order_id;

