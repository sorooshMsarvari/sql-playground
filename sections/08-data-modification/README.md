# 08 — Data modification and transactional thinking

This section changes database state with `INSERT` and `UPDATE`. The exercise checker begins a transaction, runs your statements, verifies the resulting rows, and rolls the transaction back. Your changes therefore do not accumulate between checks.

Do not put `BEGIN`, `COMMIT`, or `ROLLBACK` in these answer files; the checker owns the transaction. In a real system, preview the target rows with `SELECT`, make related changes atomically, inspect the affected-row count, verify invariants, and commit only when correct.

## Schema used in this section

### `customers`

One row represents one customer company.

| Column | Type | Null? | Key or constraint | Meaning |
|---|---|---:|---|---|
| `customer_id` | `integer` | No | Generated identity primary key | Omit this during a normal insert |
| `company_name` | `text` | No |  | Company name |
| `email` | `text` | Yes | Unique when present | Contact email |
| `phone` | `text` | Yes |  | Contact phone |
| `country` | `text` | Yes |  | Two-letter country code |
| `segment` | `text` | No | Must be `smb`, `midmarket`, or `enterprise` | Commercial segment |
| `referred_by` | `integer` | Yes | Self-FK → `customers.customer_id` | Referring customer |
| `created_at` | `date` | No |  | Acquisition date |
| `metadata` | `jsonb` | No | Default `{}` | Flexible acquisition properties |

### `categories` and `products`

| Table | Column | Type | Null? | Key or constraint |
|---|---|---|---:|---|
| `categories` | `category_id` | `integer` | No | Primary key |
| `categories` | `category_name` | `text` | No | Unique; `Stationery` is one seeded category |
| `products` | `product_id` | `integer` | No | Primary key |
| `products` | `category_id` | `integer` | No | FK → `categories.category_id` |
| `products` | `product_name` | `text` | No | Product name |
| `products` | `unit_price` | `numeric(10,2)` | No | Current price, at least zero |
| `products` | `discontinued` | `boolean` | No | Active when `false` |

The two active Stationery products start at 12.50 and 18.00. Their correctly rounded prices after a 5% increase are 13.13 and 18.90.

### `warehouses` and `inventory`

`inventory` has one row per product at one warehouse.

| Table | Column | Type | Null? | Key or constraint | Meaning |
|---|---|---|---:|---|---|
| `warehouses` | `warehouse_id` | `integer` | No | Primary key | Warehouse identifier |
| `warehouses` | `warehouse_name` | `text` | No | Unique | Display name |
| `warehouses` | `country` | `text` | No |  | Country code |
| `inventory` | `warehouse_id` | `integer` | No | Composite PK, FK → `warehouses` | Stock location |
| `inventory` | `product_id` | `integer` | No | Composite PK, FK → `products` | Stocked product |
| `inventory` | `units_in_stock` | `integer` | No | Must be at least 0 | Current units |
| `inventory` | `reorder_level` | `integer` | No | Must be at least 0 | Replenishment threshold |
| `inventory` | `last_stocked_at` | `date` | No |  | Last replenishment date |

For product 2, Berlin Central (warehouse 1) starts with 12 units and Paris West (warehouse 2) starts with 28, for a combined invariant of 40.

## Exercises

### 1. Insert a customer using the generated identity

Answer file: [`exercises/01-insert-customer.sql`](exercises/01-insert-customer.sql)

Write one `INSERT` that creates exactly this customer:

| Column | Required value |
|---|---|
| `company_name` | `Pioneer SpA` |
| `email` | `hello@pioneer.example` |
| `phone` | SQL `NULL` |
| `country` | `IT` |
| `segment` | `midmarket` |
| `referred_by` | `5` |
| `created_at` | Date `2025-03-10` |
| `metadata` | JSON object `{"channel":"event","priority":"high"}` |

List the target columns explicitly. Do not supply `customer_id`; PostgreSQL must generate it, and the checker requires it to be greater than the current maximum ID of 14. Cast the JSON literal to `jsonb` if needed.

### 2. Increase active Stationery prices

Answer file: [`exercises/02-adjust-prices.sql`](exercises/02-adjust-prices.sql)

Write one set-based `UPDATE` that increases `unit_price` by 5% for every active product in the `Stationery` category.

Requirements:

- Identify the category through `categories.category_name`; do not hard-code product IDs.
- Exclude discontinued products.
- Calculate from the existing value: `unit_price * 1.05`.
- Round the value stored back into `unit_price` to two decimal places.
- Do not change products in other categories.

The checker verifies both target prices and confirms an unrelated product price remained unchanged.

### 3. Transfer inventory without changing total stock

Answer file: [`exercises/03-transfer-inventory.sql`](exercises/03-transfer-inventory.sql)

Transfer exactly 3 units of product 2 from Berlin Central (warehouse 1) to Paris West (warehouse 2).

Write two `UPDATE` statements:

1. subtract 3 from the Berlin row's existing `units_in_stock`;
2. add 3 to the Paris row's existing `units_in_stock`.

Do not replace stock with hard-coded final values. After the statements, Berlin must contain 9, Paris must contain 31, and their combined stock must remain 40. The checker's surrounding transaction makes the pair atomic for practice and rolls it back afterward.

### 4. Insert a catalog product with a category lookup

Answer file: [`exercises/04-insert-product.sql`](exercises/04-insert-product.sql)

Insert `Ergonomic Footrest` with SKU `OFF-FOOT`, price 69.00, active status, creation date `2025-03-15`, and attributes `{"color":"black","adjustable":true}`. Resolve the `Office` category ID with a subquery and omit the generated product ID.

### 5. Upsert existing inventory

Answer file: [`exercises/05-upsert-inventory.sql`](exercises/05-upsert-inventory.sql)

Attempt to insert 5 units of product 1 at warehouse 1 with reorder level 15 and stocking date `2025-03-20`. On the composite-key conflict, add the proposed five units to existing stock and update `last_stocked_at`; preserve the existing reorder level. The result must be one row with 50 units.

### 6. Complete a processing shipment

Answer file: [`exercises/06-complete-shipment.sql`](exercises/06-complete-shipment.sql)

In one `UPDATE`, change order 1022 from `processing` to `completed` and set `shipped_at` to three days after its own `order_date`. Restrict by both order ID and current status. Do not hard-code the resulting shipping date.

### 7. Delete old failed payments

Answer file: [`exercises/07-delete-failed-payments.sql`](exercises/07-delete-failed-payments.sql)

Delete payment rows whose status is `failed` and whose `paid_at` is before `2025-01-01`. Do not delete orders. The fixture contains exactly one qualifying payment; the checker verifies the count and parent-order survival.

### 8. Repair Nomad Labs contact data

Answer file: [`exercises/08-repair-customer-contact.sql`](exercises/08-repair-customer-contact.sql)

For customer 14 only, set email to `contact@nomad.example` and country to `SE`. Do not change company name, segment, or other customers. Use the primary key as the update predicate.

### 9. Insert an order and item with a data-changing CTE

Answer file: [`exercises/09-create-order-with-item.sql`](exercises/09-create-order-with-item.sql)

Insert an order for customer 13, rep 4, date `2025-03-12`, status `pending`, country `CH`, no shipping date, and notes `Starter order`. Capture its generated ID with `RETURNING` in a CTE, then insert product 16, quantity 2, price 29.00, discount 0 into `order_items`. Do not hard-code an order ID.

### 10. Raise low Dublin reorder levels

Answer file: [`exercises/10-raise-dublin-reorder-levels.sql`](exercises/10-raise-dublin-reorder-levels.sql)

Use `UPDATE ... FROM warehouses` to add 2 to `reorder_level` for inventory in `Dublin Hub` only when current stock is strictly below the current threshold. Do not change stock quantities or rows already at/above threshold. Four seeded rows qualify.

## Running the checks

```bash
./scripts/check-section.sh 08 --only
```

A passing state exercise prints each invariant that was verified and explicitly states that changes were rolled back.
