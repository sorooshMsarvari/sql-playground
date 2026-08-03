INSERT INTO shop.tags (tag_name) VALUES ('priority') RETURNING tag_id \gset
INSERT INTO shop.customer_tags (customer_id, tag_id) VALUES (1, :tag_id);

SELECT training.assert_true(
    (SELECT count(*) = 1
     FROM shop.customer_tags ct
     JOIN shop.tags t USING (tag_id)
     WHERE ct.customer_id = 1
       AND t.tag_name = 'priority'
       AND ct.assigned_at = current_date),
    'tag and customer assignment can be inserted with the date default'
);

SELECT training.assert_true(
    (SELECT count(*) = 2
     FROM pg_constraint
     WHERE conrelid = 'shop.customer_tags'::regclass
       AND contype = 'f'
       AND confdeltype = 'c'),
    'both customer_tags foreign keys cascade on deletion'
);

