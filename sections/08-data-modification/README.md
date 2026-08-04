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

Insert exactly one new catalog product with the following state:

| Column | Required value |
|---|---|
| `sku` | `OFF-FOOT` |
| `product_name` | `Ergonomic Footrest` |
| `category_id` | ID looked up from the category named `Office` |
| `unit_price` | `69.00` |
| `discontinued` | `false` |
| `attributes` | JSON object `{"color":"black","adjustable":true}` |
| `created_at` | Date `2025-03-15` |

Requirements:

- List the target product columns explicitly.
- Resolve the category ID with a scalar subquery against `categories`; do not hard-code it.
- Omit `product_id` so PostgreSQL generates the identity value.
- Store `attributes` as `jsonb`.

Expected edge case: a category name is the supplied business key, while the product row requires its numeric foreign key.

### 5. Upsert existing inventory

Answer file: [`exercises/05-upsert-inventory.sql`](exercises/05-upsert-inventory.sql)

Upsert inventory for the existing `(warehouse_id, product_id)` pair `(1, 1)`.

| Proposed column | Inserted value |
|---|---|
| `warehouse_id` | `1` |
| `product_id` | `1` |
| `units_in_stock` | `5` |
| `reorder_level` | `15` |
| `last_stocked_at` | Date `2025-03-20` |

Requirements:

- Use `ON CONFLICT` with the composite key `(warehouse_id, product_id)`.
- On conflict, add `excluded.units_in_stock` to the existing stock rather than replacing it.
- Update `last_stocked_at` from the proposed row.
- Preserve the existing `reorder_level` during the conflict update.
- Leave exactly one inventory row for the key, with 50 units in stock.

Expected edge case: the proposed reorder level belongs to the insert branch and must not overwrite the existing value when the conflict branch runs.

### 6. Complete a processing shipment

Answer file: [`exercises/06-complete-shipment.sql`](exercises/06-complete-shipment.sql)

Complete the shipment for order 1022 with one `UPDATE`.

Required resulting state:

| Column | Required value |
|---|---|
| `status` | `completed` |
| `shipped_at` | The row's own `order_date + 3` days |

Requirements:

- Restrict the update by both `order_id = 1022` and current status `processing`.
- Calculate the shipping date from `order_date`; do not hard-code a calendar date.
- Change no unrelated order.

Expected edge case: checking the current status prevents the statement from completing an order that has already moved to another lifecycle state.

### 7. Delete old failed payments

Answer file: [`exercises/07-delete-failed-payments.sql`](exercises/07-delete-failed-payments.sql)

Delete old failed payment events while preserving their parent orders.

Deletion criteria:

- `payments.status` is exactly `failed`.
- `paid_at` is strictly earlier than `2025-01-01`.

Use one `DELETE FROM payments` statement with both conditions. Do not delete from `orders`, and do not remove failed payments on or after the boundary date.

The fixture contains exactly one qualifying payment. The checker verifies that one row is removed and that its related order still exists.

Expected edge case: payment lifecycle and order lifecycle are separate; deleting a payment event must not mean deleting its order.

### 8. Repair Nomad Labs contact data

Answer file: [`exercises/08-repair-customer-contact.sql`](exercises/08-repair-customer-contact.sql)

Repair two missing contact fields for Nomad Labs.

| Target | Required value |
|---|---|
| Customer predicate | `customer_id = 14` |
| `email` | `contact@nomad.example` |
| `country` | `SE` |

Requirements:

- Use one `UPDATE` against `customers`.
- Identify the row by its primary key.
- Change only `email` and `country`.
- Preserve company name, segment, referral, dates, metadata, and every other customer row.

Expected edge case: using company name as the predicate is less precise than the supplied stable primary key.

### 9. Insert an order and item with a data-changing CTE

Answer file: [`exercises/09-create-order-with-item.sql`](exercises/09-create-order-with-item.sql)

Create one order and its first item in a single data-changing CTE statement.

New order values:

| Column | Required value |
|---|---|
| `customer_id` | `13` |
| `sales_rep_id` | `4` |
| `order_date` | Date `2025-03-12` |
| `status` | `pending` |
| `shipping_country` | `CH` |
| `shipped_at` | SQL `NULL` |
| `notes` | `Starter order` |

New item values:

| Column | Required value |
|---|---|
| `order_id` | Generated ID returned by the order insert |
| `product_id` | `16` |
| `quantity` | `2` |
| `unit_price` | `29.00` |
| `discount` | `0` |

Use `RETURNING order_id` inside a CTE and select that value into the item insert. Do not hard-code or predict the generated order ID.

Expected edge case: the item must reference the exact identity generated by the order insert in the same statement.

### 10. Raise low Dublin reorder levels

Answer file: [`exercises/10-raise-dublin-reorder-levels.sql`](exercises/10-raise-dublin-reorder-levels.sql)

Increase reorder thresholds for low-stock inventory at Dublin Hub. One statement must update all qualifying rows as a set.

Requirements:

- Use `UPDATE ... FROM warehouses` and join by `warehouse_id`.
- Restrict the warehouse by the exact name `Dublin Hub`.
- Update only rows where `units_in_stock < reorder_level` before the change.
- Add 2 to each row's existing `reorder_level`.
- Do not change `units_in_stock`, other warehouses, or Dublin rows already at or above threshold.

Four seeded rows qualify. The checker verifies both the changed rows and the rows that must remain unchanged.

Expected edge case: equality with the reorder level is not low stock and must not trigger an update.

## Running the checks

```bash
./scripts/check-section.sh 08 --only
```

A passing state exercise prints each invariant that was verified and explicitly states that changes were rolled back.
