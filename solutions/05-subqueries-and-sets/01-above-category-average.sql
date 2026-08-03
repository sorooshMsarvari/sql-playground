SELECT p.product_id, p.product_name, p.category_id, p.unit_price
FROM products p
WHERE p.discontinued = false
  AND p.unit_price > (
      SELECT avg(peer.unit_price)
      FROM products peer
      WHERE peer.category_id = p.category_id
        AND peer.discontinued = false
  )
ORDER BY p.category_id, p.unit_price DESC, p.product_id;

