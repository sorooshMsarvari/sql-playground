# 09 — Schema design and performance

This section moves from querying existing data to designing database interfaces. You will encode integrity in a new table, create an index for a concrete lookup pattern, and package a trustworthy aggregate as a view. The checker creates each object inside a transaction, inspects or exercises it, and rolls it back.

Do not add transaction-control statements to the answer files.

## Existing schema used in this section

### `products`

The new review table will reference the existing product primary key.

| Column | Type | Null? | Key or meaning |
|---|---|---:|---|
| `product_id` | `integer` | No | Generated identity primary key |
| `sku` | `text` | No | Unique product code |
| `product_name` | `text` | No | Product name |
| `category_id` | `integer` | No | FK → `categories.category_id` |
| `unit_price` | `numeric(10,2)` | No | Current catalog price |
| `discontinued` | `boolean` | No | Lifecycle flag |

### `orders`

The index and view both use this table.

| Column | Type | Null? | Key or constraint | Meaning |
|---|---|---:|---|---|
| `order_id` | `integer` | No | Primary key | Order identifier |
| `customer_id` | `integer` | No | FK → `customers.customer_id` | Lookup's leading filter column |
| `sales_rep_id` | `integer` | Yes | FK → `employees.employee_id` | Assigned representative |
| `order_date` | `date` | No |  | Lookup's descending time column |
| `status` | `text` | No | Five allowed states | Included index payload and view filter |
| `shipping_country` | `text` | No |  | Destination |
| `shipped_at` | `date` | Yes | Not before order date | Shipping date |
| `notes` | `text` | Yes |  | Operational note |

### `order_items`

The view aggregates historical item data.

| Column | Type | Null? | Key or meaning |
|---|---|---:|---|
| `order_id` | `integer` | No | Composite PK, FK → `orders.order_id` |
| `product_id` | `integer` | No | Composite PK, FK → `products.product_id` |
| `quantity` | `integer` | No | Units |
| `unit_price` | `numeric(10,2)` | No | Historical unit price |
| `discount` | `numeric(4,3)` | No | Fractional discount |

## Exercises

### 1. Define `shop.product_reviews`

Answer file: [`exercises/01-product-reviews-table.sql`](exercises/01-product-reviews-table.sql)

Create a table named exactly `shop.product_reviews` with this contract:

| Column | Required definition |
|---|---|
| `review_id` | `integer`, generated identity, primary key |
| `product_id` | `integer`, `NOT NULL`, FK to `shop.products(product_id)`, `ON DELETE CASCADE` |
| `rating` | `integer`, `NOT NULL`, check constraint allowing only 1 through 5 inclusive |
| `body` | `text`, nullable |
| `created_at` | `timestamptz`, `NOT NULL`, default `current_timestamp` |

Use one `CREATE TABLE` statement. The checker does more than inspect names: it inserts a valid review, verifies the timestamp default, tries an invalid rating, and confirms that the foreign key's deletion action is cascade.

### 2. Create a covering customer/date index

Answer file: [`exercises/02-order-lookup-index.sql`](exercises/02-order-lookup-index.sql)

Create an index named exactly `idx_orders_customer_date` on `shop.orders` for queries shaped like:

```sql
SELECT status
FROM shop.orders
WHERE customer_id = ?
  AND order_date >= ?
ORDER BY order_date DESC;
```

Index contract:

- First key: `customer_id` ascending, the default.
- Second key: `order_date DESC`.
- Non-key included column: `status`, using `INCLUDE`.
- Do not include unrelated columns.

After it passes, experiment manually:

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT status
FROM shop.orders
WHERE customer_id = 1
ORDER BY order_date DESC;
```

The seed table is intentionally tiny, so PostgreSQL may choose a sequential scan even when the index is correct. An index makes a plan available; it does not force the planner to use it.

### 3. Create a completed-order totals view

Answer file: [`exercises/03-completed-order-view.sql`](exercises/03-completed-order-view.sql)

Create `shop.completed_order_totals` as a normal view with exactly one row per completed order.

| View column | Definition |
|---|---|
| `order_id` | `orders.order_id` |
| `customer_id` | `orders.customer_id` |
| `order_date` | `orders.order_date` |
| `total_amount` | Sum of `quantity * unit_price * (1 - discount)`, rounded to two decimals |

Join orders to order items, filter to `status = 'completed'`, and group at the order grain. Do not put `ORDER BY` in the view; consumers decide display order. The checker compares every view row and value in both directions against an independently calculated expected set.

### 4. Partial index for open orders

Answer file: [`exercises/04-open-orders-partial-index.sql`](exercises/04-open-orders-partial-index.sql)

Create a partial index for date-oriented access to open orders.

| Index property | Required definition |
|---|---|
| Name | `idx_orders_open_date` |
| Table | `shop.orders` |
| First key | `order_date` ascending |
| Second key | `customer_id` ascending |
| Included rows | Status `pending` or `processing` only |

Requirements:

- Use one `CREATE INDEX` statement.
- Keep the key order exactly as listed.
- Express the open-status condition as the partial index's `WHERE` predicate.
- Do not include completed, cancelled, or refunded rows.

Expected edge case: the predicate must contain both open status values; indexing only one produces an incomplete access path.

### 5. Case-insensitive customer-email index

Answer file: [`exercises/05-customer-email-expression-index.sql`](exercises/05-customer-email-expression-index.sql)

Create an expression index for case-insensitive customer-email lookup.

| Index property | Required definition |
|---|---|
| Name | `idx_customers_lower_email` |
| Table | `shop.customers` |
| Indexed expression | `lower(email)` |
| Included rows | Rows where `email IS NOT NULL` |

Requirements:

- Index the normalized expression, not the raw email column.
- Use a partial `WHERE` predicate to exclude missing emails.
- Do not add unrelated key or included columns.

Expected edge case: a query can use this index only when its lookup expression is compatible with the indexed normalization.

### 6. Materialized category sales snapshot

Answer file: [`exercises/06-category-sales-materialized-view.sql`](exercises/06-category-sales-materialized-view.sql)

Create `shop.category_sales_snapshot` as a materialized category-level sales report. One stored row must represent one category, including a category with no completed sales.

| View column | Definition |
|---|---|
| `category_id` | Category identifier |
| `category_name` | Category name |
| `completed_units` | Sum of quantities on completed orders, or zero |
| `completed_revenue` | Discounted completed-order revenue, zero-filled and rounded to two decimals |

Requirements:

- Use `CREATE MATERIALIZED VIEW`, not a normal view or table.
- Preserve every category through the products, items, and orders relationships.
- Apply completed status only to the two aggregates without removing zero-sale categories.
- Use `quantity * unit_price * (1 - discount)` for revenue.
- Do not put `ORDER BY` in the stored definition.

Expected edge case: filtering completed orders as a final row predicate would remove categories that require zero-valued snapshot rows.

### 7. Add constrained product weight

Answer file: [`exercises/07-add-product-weight.sql`](exercises/07-add-product-weight.sql)

Alter the existing product table to support an optional positive weight.

| Column property | Required definition |
|---|---|
| Table | `shop.products` |
| Column name | `weight_grams` |
| Type | `integer` |
| Nullability | Nullable |
| Check | A present value must be greater than zero |
| Default | None |

Use one `ALTER TABLE ... ADD COLUMN` statement. Do not add `NOT NULL` or a default value. The checker stores a positive weight and confirms that a negative update violates the check.

Expected edge case: PostgreSQL check constraints permit `NULL` unless nullability is separately prohibited, which is required here.

### 8. Design customer tags

Answer file: [`exercises/08-customer-tags-schema.sql`](exercises/08-customer-tags-schema.sql)

Create a tag table and a many-to-many customer/tag junction table.

`shop.tags` contract:

| Column | Required definition |
|---|---|
| `tag_id` | Generated `integer` identity primary key |
| `tag_name` | `text NOT NULL UNIQUE` |

`shop.customer_tags` contract:

| Column | Required definition |
|---|---|
| `customer_id` | `integer NOT NULL`, FK to `shop.customers(customer_id)`, `ON DELETE CASCADE` |
| `tag_id` | `integer NOT NULL`, FK to `shop.tags(tag_id)`, `ON DELETE CASCADE` |
| `assigned_at` | `date NOT NULL DEFAULT current_date` |

Use the composite primary key `(customer_id, tag_id)` so the same tag cannot be assigned to one customer twice. Create `shop.tags` before the junction table because the second statement references it.

Expected edge case: both foreign keys require cascading deletion; configuring only one cascade leaves an asymmetric relationship.

## Running the checks

```bash
./scripts/check-section.sh 09 --only
```
