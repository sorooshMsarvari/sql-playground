-- CAPSTONE: rank customers by completed-order lifetime revenue within their segment.
-- Build one row per completed order, then customer metrics, then rank.
-- Include customers with at least one completed order only.
-- Columns:
--   segment
--   revenue_rank: DENSE_RANK within segment, highest revenue first
--   customer_id
--   company_name
--   acquisition_channel: metadata channel, or 'unknown'
--   completed_orders
--   lifetime_revenue rounded to 2 decimals
--   first_order
--   last_order
-- Return only ranks 1 and 2. Sort by segment, revenue_rank, customer_id.

-- TODO
SELECT segment, 0::bigint AS revenue_rank, customer_id, company_name,
       ''::text AS acquisition_channel, 0::bigint AS completed_orders,
       0::numeric AS lifetime_revenue, NULL::date AS first_order, NULL::date AS last_order
FROM customers
WHERE false;

