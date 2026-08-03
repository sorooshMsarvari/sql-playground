WITH RECURSIVE referral_tree AS (
    SELECT c.customer_id,
           c.company_name,
           0 AS depth,
           c.company_name::text AS referral_path
    FROM customers c
    WHERE c.customer_id = 1

    UNION ALL

    SELECT child.customer_id,
           child.company_name,
           parent.depth + 1,
           parent.referral_path || ' > ' || child.company_name
    FROM customers child
    JOIN referral_tree parent ON parent.customer_id = child.referred_by
)
SELECT customer_id, company_name, depth, referral_path
FROM referral_tree
ORDER BY referral_path;

