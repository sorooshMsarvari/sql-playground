WITH category_revenue AS (
    SELECT c.category_id,
           c.category_name,
           sum(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
    FROM categories c
    JOIN products p ON p.category_id = c.category_id
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status = 'completed'
    GROUP BY c.category_id, c.category_name
), grand_total AS (
    SELECT sum(revenue) AS revenue FROM category_revenue
)
SELECT cr.category_name,
       round(cr.revenue, 2) AS category_revenue,
       round(100 * cr.revenue / gt.revenue, 2) AS revenue_percent
FROM category_revenue cr
CROSS JOIN grand_total gt
ORDER BY category_revenue DESC, cr.category_name;

