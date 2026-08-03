SELECT c.category_name,
       p.product_id,
       p.product_name,
       p.unit_price
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.discontinued = false
  AND p.unit_price = (
      SELECT max(peer.unit_price)
      FROM products peer
      WHERE peer.category_id = p.category_id
        AND peer.discontinued = false
  )
ORDER BY c.category_name, p.product_id;

