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

## Running the checks

```bash
./scripts/check-section.sh 09 --only
```

