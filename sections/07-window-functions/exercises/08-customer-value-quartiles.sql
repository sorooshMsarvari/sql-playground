-- Write the query defined in this section's README.
SELECT customer_id, company_name, 0::numeric AS lifetime_revenue,
       0::integer AS value_quartile
FROM customers
WHERE false;

