# SQL guide for this playground

This guide follows the ten playground sections. Read it in order: a concept is explained only where it first appears. Later sections use earlier concepts without teaching them again.

## Before section 01: what SQL works with

A **database** stores data. A **table** is a named collection of data, a **row** is one item, and a **column** is one property of that item. A **query** asks the database for a result.

SQL keywords are commonly written in uppercase for readability, but PostgreSQL does not require it. Text uses single quotes. A statement normally ends with `;`.

`--` starts a comment that continues to the end of the line.

```sql
SELECT 'hello';
```

## 01 — Query foundations

### `SELECT`, `FROM`, and `AS`

`SELECT` chooses result columns. `FROM` chooses the table. `AS` gives a result column a new name.

```sql
SELECT product_name AS name, unit_price AS price
FROM products;
```

`SELECT *` chooses every column. Prefer named columns when you need only part of a table.

### `WHERE` and comparisons

`WHERE` keeps rows whose condition is true. Common comparisons are `=`, `<>`, `<`, `<=`, `>`, and `>=`. PostgreSQL has boolean values `true` and `false`.

```sql
SELECT product_name
FROM products
WHERE discontinued = false;
```

### `AND`, `OR`, and parentheses

`AND` requires both conditions. `OR` requires either condition. Use parentheses when conditions are mixed.

```sql
SELECT company_name
FROM customers
WHERE segment = 'enterprise'
   OR (segment = 'midmarket' AND country = 'PT');
```

### `IN`, `NOT IN`, and `BETWEEN`

`IN` matches a list. `NOT IN` rejects a list. `BETWEEN` includes both endpoints.

```sql
SELECT order_id
FROM orders
WHERE status IN ('pending', 'processing')
  AND order_date BETWEEN DATE '2024-01-01' AND DATE '2024-12-31';
```

`DATE '2024-01-01'` is a typed date literal, not ordinary text.

### `LIKE` and `ILIKE`

`LIKE` matches a text pattern; `ILIKE` ignores letter case. `%` means any sequence of characters and `_` means one character.

```sql
SELECT product_name
FROM products
WHERE product_name ILIKE '%desk%';
```

### `DISTINCT`

`DISTINCT` removes duplicate result rows.

```sql
SELECT DISTINCT shipping_country
FROM orders;
```

### `ORDER BY`, `LIMIT`, and `OFFSET`

`ORDER BY` sorts results. `ASC` is ascending and `DESC` is descending. `LIMIT` restricts row count; `OFFSET` skips rows. Always sort before paginating.

```sql
SELECT product_id, product_name
FROM products
ORDER BY product_id ASC
LIMIT 5 OFFSET 5;
```

## 02 — Expressions, NULLs, text, and dates

### Expressions and arithmetic

An expression calculates a value. SQL supports `+`, `-`, `*`, and `/`; parentheses control calculation order.

```sql
SELECT quantity * unit_price * (1 - discount) AS line_total
FROM order_items;
```

`round(value, digits)` rounds a numeric value.

### `NULL`, `IS NULL`, and `IS NOT NULL`

`NULL` means missing or unknown. It is not zero or empty text. Test it with `IS NULL` or `IS NOT NULL`, never `= NULL`.

```sql
SELECT customer_id
FROM customers
WHERE phone IS NULL;
```

### `COALESCE` and `NULLIF`

`COALESCE` returns the first non-`NULL` value. `NULLIF(a, b)` returns `NULL` when the values are equal.

```sql
SELECT coalesce(nullif(btrim(notes), ''), 'none') AS note_text
FROM orders;
```

### `CASE`

`CASE` chooses a result by testing conditions from top to bottom.

```sql
SELECT product_name,
       CASE
           WHEN unit_price < 50 THEN 'budget'
           ELSE 'standard'
       END AS price_band
FROM products;
```

### Text functions and `||`

`||` joins text. Useful functions here include `lower`, `upper`, `left`, `btrim`, and `split_part`.

```sql
SELECT lower(first_name || '.' || last_name) AS username
FROM employees;
```

### Type casts with `::`

A cast converts a value to another type.

```sql
SELECT extract(year FROM order_date)::integer AS order_year
FROM orders;
```

### Date operations and formatting

Subtracting one `date` from another returns days. `extract` reads a date part. `to_char` formats a value as text.

```sql
SELECT order_id,
       shipped_at - order_date AS shipping_days,
       to_char(order_date, 'YYYY-MM-DD') AS displayed_date
FROM orders;
```

## 03 — Aggregation and grouping

### Aggregate functions

Aggregates summarize rows: `count`, `sum`, `avg`, `min`, and `max`.

```sql
SELECT count(*) AS customer_count, min(created_at) AS first_customer
FROM customers;
```

### `GROUP BY`

`GROUP BY` creates one result group for each distinct grouping value. Selected columns must normally be grouped or aggregated.

```sql
SELECT country, count(*) AS customer_count
FROM customers
GROUP BY country;
```

### `HAVING`

`WHERE` filters input rows; `HAVING` filters completed groups.

```sql
SELECT customer_id, count(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING count(*) > 1;
```

### `JOIN` and `ON`

`JOIN` combines related rows. `ON` states how their keys match. An ordinary `JOIN` keeps matches only.

Short table aliases such as `o` and `oi` keep qualified names like `o.order_id` readable. PostgreSQL allows the table alias without `AS`.

```sql
SELECT o.order_id, oi.product_id
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id;
```

### `LEFT JOIN`

`LEFT JOIN` keeps every left-side row. Missing right-side columns become `NULL`.

```sql
SELECT c.customer_id, count(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id;
```

Count a nullable right-side key—not `count(*)`—when unmatched rows should count as zero.

### Aggregate `FILTER` and aggregate `DISTINCT`

`FILTER` limits rows for one aggregate. `DISTINCT` inside an aggregate prevents duplicate values from being counted.

```sql
SELECT count(DISTINCT order_id) AS orders,
       count(*) FILTER (WHERE status = 'completed') AS completed
FROM orders;
```

### `WITH` common table expressions

`WITH` names an intermediate query so a larger query can be read in stages.

```sql
WITH completed AS (
    SELECT * FROM orders WHERE status = 'completed'
)
SELECT count(*)
FROM completed;
```

### Grouping helpers

`date_trunc` reduces a date to a period such as a month. `greatest` returns the largest argument.

```sql
SELECT date_trunc('month', order_date)::date AS month_start,
       count(*)
FROM orders
GROUP BY month_start;
```

## 04 — Joins and relationships

This section applies the earlier join syntax to more relationship shapes.

### Table aliases in self joins

A self join uses the same table twice. Different aliases give each use a role.

```sql
SELECT employee.first_name, manager.first_name AS manager_name
FROM employees employee
LEFT JOIN employees manager ON manager.employee_id = employee.manager_id;
```

### `CROSS JOIN`

`CROSS JOIN` creates every possible pair. Three warehouses crossed with five products produces fifteen rows before filtering.

```sql
SELECT w.warehouse_id, p.product_id
FROM warehouses w
CROSS JOIN products p;
```

### Anti-matching with `LEFT JOIN`

To find missing relationships, left join and keep rows whose right-side key is `NULL`.

```sql
SELECT o.order_id
FROM orders o
LEFT JOIN payments p ON p.order_id = o.order_id
WHERE p.payment_id IS NULL;
```

## 05 — Subqueries and set operations

### Scalar and correlated subqueries

A subquery is a query inside another query. A correlated subquery refers to the current outer row.

```sql
SELECT p.product_name
FROM products p
WHERE p.unit_price > (
    SELECT avg(peer.unit_price)
    FROM products peer
    WHERE peer.category_id = p.category_id
);
```

### `EXISTS` and `NOT EXISTS`

`EXISTS` tests whether a subquery returns at least one row. `NOT EXISTS` tests that it returns none.

```sql
SELECT c.company_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);
```

### `UNION`, `EXCEPT`, and `INTERSECT`

These combine compatible result sets. `UNION` combines and removes duplicates, `EXCEPT` keeps rows only in the first set, and `INTERSECT` keeps rows in both. `UNION ALL` keeps duplicates.

```sql
SELECT country FROM customers WHERE country IS NOT NULL
INTERSECT
SELECT country FROM warehouses;
```

### `LATERAL`

`LATERAL` lets a joined subquery use columns from rows before it.

```sql
SELECT c.customer_id, latest.order_id
FROM customers c
LEFT JOIN LATERAL (
    SELECT order_id
    FROM orders o
    WHERE o.customer_id = c.customer_id
    ORDER BY order_date DESC
    LIMIT 1
) latest ON true;
```

## 06 — CTEs, recursion, and generated series

### `WITH RECURSIVE`

A recursive CTE has an anchor query and a recursive query. The recursive query uses rows already found. It must eventually stop finding new rows.

```sql
WITH RECURSIVE organization AS (
    SELECT employee_id, manager_id, 0 AS depth
    FROM employees
    WHERE employee_id = 1

    UNION ALL

    SELECT child.employee_id, child.manager_id, parent.depth + 1
    FROM employees child
    JOIN organization parent ON child.manager_id = parent.employee_id
)
SELECT * FROM organization;
```

### `generate_series` and `INTERVAL`

`generate_series` creates rows between two values. An `INTERVAL` represents a duration.

```sql
SELECT day::date
FROM generate_series(
    DATE '2024-01-01',
    DATE '2024-01-07',
    INTERVAL '1 day'
) day;
```

## 07 — Window functions

### `OVER`, `PARTITION BY`, and window ordering

A window function calculates across related rows without collapsing them. `PARTITION BY` creates independent groups; window `ORDER BY` defines sequence.

```sql
SELECT customer_id, order_id,
       row_number() OVER (
           PARTITION BY customer_id
           ORDER BY order_date
       ) AS order_number
FROM orders;
```

### Ranking functions

`row_number` always assigns unique numbers. `rank` leaves gaps after ties. `dense_rank` does not leave gaps.

```sql
SELECT product_name,
       dense_rank() OVER (ORDER BY unit_price DESC) AS price_rank
FROM products;
```

### `LAG` and `LEAD`

`lag` reads an earlier row in the window; `lead` reads a later row.

```sql
SELECT order_id, order_date,
       lag(order_date) OVER (
           PARTITION BY customer_id ORDER BY order_date
       ) AS previous_order_date
FROM orders;
```

### Window frames

A frame chooses which ordered rows contribute to the current calculation.

```sql
SELECT product_id,
       avg(unit_price) OVER (
           ORDER BY product_id
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS moving_average
FROM products;
```

`last_value` usually needs a frame ending at `UNBOUNDED FOLLOWING`; otherwise its default frame ends at the current row.

### Other window functions

`ntile(n)` divides ordered rows into buckets. `first_value` and `last_value` read frame endpoints. `percent_rank` returns relative rank from 0 to 1.

```sql
SELECT product_id,
       ntile(4) OVER (ORDER BY unit_price DESC) AS price_quartile
FROM products;
```

## 08 — Data modification and transactions

### Transactions: `BEGIN`, `COMMIT`, and `ROLLBACK`

A transaction makes related changes one unit. `COMMIT` saves them; `ROLLBACK` discards them. The playground checker supplies a transaction and rolls state exercises back.

```sql
BEGIN;
UPDATE inventory SET units_in_stock = units_in_stock + 1 WHERE product_id = 1;
ROLLBACK;
```

### `INSERT INTO` and `VALUES`

`INSERT` adds rows. List columns explicitly; omitted identity columns are generated.

```sql
INSERT INTO categories (category_name)
VALUES ('Temporary category');
```

### `UPDATE` and `SET`

`UPDATE` changes matching rows. Always inspect the `WHERE` condition; without it, every row changes.

```sql
UPDATE products
SET unit_price = round(unit_price * 1.05, 2)
WHERE category_id = 3;
```

### `DELETE FROM`

`DELETE` removes matching rows. It has the same missing-`WHERE` danger as `UPDATE`.

```sql
DELETE FROM payments
WHERE status = 'failed';
```

### `ON CONFLICT`, `DO UPDATE`, and `excluded`

An upsert inserts a row or handles a unique-key conflict. `excluded` is the row that PostgreSQL attempted to insert.

```sql
INSERT INTO inventory (warehouse_id, product_id, units_in_stock, reorder_level, last_stocked_at)
VALUES (1, 1, 5, 10, current_date)
ON CONFLICT (warehouse_id, product_id)
DO UPDATE SET units_in_stock = inventory.units_in_stock + excluded.units_in_stock;
```

### `RETURNING` and data-changing CTEs

`RETURNING` exposes values written by a statement, including generated IDs. A CTE can pass that value to another statement.

```sql
WITH new_category AS (
    INSERT INTO categories (category_name) VALUES ('Returned category')
    RETURNING category_id
)
SELECT category_id FROM new_category;
```

### `UPDATE ... FROM`

PostgreSQL can use another table to decide which rows to update.

```sql
UPDATE inventory i
SET reorder_level = reorder_level + 1
FROM warehouses w
WHERE w.warehouse_id = i.warehouse_id
  AND w.country = 'IE';
```

## 09 — Schema design and performance

### Schemas and qualified names

A schema groups database objects. `shop.products` means table `products` inside schema `shop`.

### `CREATE TABLE`, data types, and constraints

`CREATE TABLE` defines stored structure. Common types here are `integer`, `text`, `numeric`, `boolean`, `date`, `timestamptz`, and `jsonb`.

Constraints protect data: `PRIMARY KEY`, `FOREIGN KEY`/`REFERENCES`, `UNIQUE`, `NOT NULL`, `CHECK`, and `DEFAULT`. `ON DELETE CASCADE` removes dependent rows when their referenced row is deleted.

```sql
CREATE TABLE shop.example_tags (
    tag_id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    tag_name text NOT NULL UNIQUE,
    created_at date NOT NULL DEFAULT current_date
);
```

### `CREATE INDEX`

An index can speed a matching access pattern. Column order matters. `INCLUDE` stores non-key columns; a partial index has `WHERE`; an expression index indexes a calculation.

```sql
CREATE INDEX example_order_lookup
ON shop.orders (customer_id, order_date DESC)
INCLUDE (status)
WHERE status = 'completed';
```

Use `EXPLAIN (ANALYZE, BUFFERS)` to inspect the plan PostgreSQL actually used.

### Views and materialized views

A view stores a query definition. A materialized view stores its result and must be refreshed when source data changes.

```sql
CREATE VIEW shop.active_products AS
SELECT product_id, product_name
FROM shop.products
WHERE discontinued = false;
```

### `ALTER TABLE`

`ALTER TABLE` changes an existing table definition.

```sql
ALTER TABLE shop.products
ADD COLUMN example_note text;
```

## 10 — PostgreSQL JSONB and capstones

### JSONB extraction and containment

`->>` extracts a JSON value as SQL text. `@>` tests whether JSONB contains another JSON value.

```sql
SELECT product_name, attributes ->> 'color' AS color
FROM products
WHERE attributes @> '{"wireless": true}'::jsonb;
```

### `jsonb_build_object` and `jsonb_agg`

`jsonb_build_object` creates an object. `jsonb_agg` collects values into an array.

```sql
SELECT category_id,
       jsonb_agg(jsonb_build_object('name', product_name) ORDER BY product_name) AS products
FROM products
GROUP BY category_id;
```

### `DISTINCT ON`

PostgreSQL's `DISTINCT ON` keeps the first ordered row for each key. The `ORDER BY` must begin with the same key.

```sql
SELECT DISTINCT ON (customer_id)
       customer_id, order_id, order_date
FROM orders
ORDER BY customer_id, order_date DESC, order_id DESC;
```

## How to use this guide

Read one guide section, then work only on the matching exercise section. When a later query uses an unfamiliar earlier keyword, search this document for its first explanation rather than learning it again from a second definition.
