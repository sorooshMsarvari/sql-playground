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

## Running the checks

```bash
./scripts/check-section.sh 08 --only
```

A passing state exercise prints each invariant that was verified and explicitly states that changes were rolled back.

