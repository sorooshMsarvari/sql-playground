# 05 — Subqueries and set operations

Subqueries let one result answer a question needed by another query. Set operations combine complete row sets. This section emphasizes choosing the correct tool: a correlated scalar value, an existence test, independently aggregated facts, or a union of compatible outputs.

## Schema used in this section

### Catalog tables

`categories` contains one row per category; `products` contains many products per category.

| Table | Column | Type | Null? | Key or meaning |
|---|---|---|---:|---|
| `categories` | `category_id` | `integer` | No | Primary key |
| `categories` | `category_name` | `text` | No | Unique category name |
| `products` | `product_id` | `integer` | No | Primary key |
| `products` | `product_name` | `text` | No | Product display name |
| `products` | `category_id` | `integer` | No | FK → `categories.category_id` |
| `products` | `unit_price` | `numeric(10,2)` | No | Current catalog price |
| `products` | `discontinued` | `boolean` | No | `false` means active |

### Customer and order tables

```text
customers (1) ──< orders (1) ──< order_items
                         (1) ──< payments
```

| Table | Column | Type | Null? | Key or meaning |
|---|---|---|---:|---|
| `customers` | `customer_id` | `integer` | No | Primary key |
| `customers` | `company_name` | `text` | No | Company name |
| `customers` | `country` | `text` | Yes | Two-letter country code |
| `orders` | `order_id` | `integer` | No | Primary key |
| `orders` | `customer_id` | `integer` | No | FK → `customers.customer_id` |
| `orders` | `status` | `text` | No | Order lifecycle state |
| `order_items` | `order_id` | `integer` | No | FK → `orders.order_id`; composite PK part |
| `order_items` | `product_id` | `integer` | No | FK → `products.product_id`; composite PK part |
| `order_items` | `quantity` | `integer` | No | Units sold |
| `order_items` | `unit_price` | `numeric(10,2)` | No | Historical price per unit |
| `order_items` | `discount` | `numeric(4,3)` | No | Fractional discount |

Customers 13 and 14 have no orders, and products 16 and 17 have no order items, which makes them useful anti-join cases.

### `payments`

One row represents one payment event or attempt. An order can have multiple payment rows.

| Column | Type | Null? | Key or constraint | Meaning |
|---|---|---:|---|---|
| `payment_id` | `integer` | No | Primary key | Payment-event identifier |
| `order_id` | `integer` | No | FK → `orders.order_id` | Related order |
| `paid_at` | `date` | No |  | Payment date |
| `amount` | `numeric(10,2)` | No | Greater than 0 | Payment amount |
| `method` | `text` | No | `card`, `bank_transfer`, or `paypal` | Payment rail |
| `status` | `text` | No | `pending`, `succeeded`, `failed`, or `refunded` | Outcome |

Never join raw `order_items` and raw `payments` and then sum both. If an order has three items and two payments, that join creates six rows and multiplies both totals. Aggregate each fact table to one row per order first.

### `warehouses`

One row represents one warehouse.

| Column | Type | Null? | Key or meaning |
|---|---|---:|---|
| `warehouse_id` | `integer` | No | Primary key |
| `warehouse_name` | `text` | No | Unique display name |
| `country` | `text` | No | Two-letter warehouse country code |

## Exercises

### 1. Products above their category average

Answer file: [`exercises/01-above-category-average.sql`](exercises/01-above-category-average.sql)

Find every active product whose price is strictly greater than the average price of active products in that same category.

Return `product_id`, `product_name`, `category_id`, and `unit_price`, in that order. Sort by `category_id` ascending, `unit_price` descending, and `product_id` ascending.

Required approach and semantics:

- Use a correlated scalar subquery to calculate the average for the current outer product's category.
- Exclude discontinued products from both the outer candidates and the inner category average.
- “Above average” is strict: a product equal to the average does not qualify.
- Do not calculate one global average across all categories.

### 2. Customers without orders

Answer file: [`exercises/02-customers-without-orders.sql`](exercises/02-customers-without-orders.sql)

Find customers for which no order row exists.

Return `customer_id` and `company_name`, sorted by `customer_id` ascending. Use a correlated `NOT EXISTS` subquery. The subquery can select `1` because only existence matters; no values from it are returned.

This asks about all orders, regardless of status. A customer with only a cancelled order still has an order and must not appear.

### 3. Completed-order payment reconciliation

Answer file: [`exercises/03-payment-reconciliation.sql`](exercises/03-payment-reconciliation.sql)

Find completed orders for which the successful-payment total differs from the discounted item total by at least one cent.

Build two independent aggregates:

1. `order_totals`: one row per completed order, summing `quantity * unit_price * (1 - discount)`;
2. `payment_totals`: one row per order, summing only payments whose status is `succeeded`.

Then join those order-level results. A completed order with no successful payment has a paid total of zero.

| Output column | Definition |
|---|---|
| `order_id` | Completed order identifier |
| `order_total` | Discounted item total, rounded to two decimals |
| `paid_total` | Successful-payment total, or zero, rounded to two decimals |
| `difference` | `paid_total - order_total`, rounded to two decimals |

Exclude rows whose absolute unrounded difference is less than `0.01`. Sort by absolute difference descending and then `order_id` ascending. Preserve the sign: underpayment is negative and overpayment is positive.

### 4. Countries with customer or warehouse presence

Answer file: [`exercises/04-market-presence.sql`](exercises/04-market-presence.sql)

Create a two-column set describing where the business has customers and warehouses.

First row set:

- Take non-`NULL` countries from `customers`.
- Label every row with `presence_type = 'customer'`.

Second row set:

- Take countries from `warehouses`.
- Label every row with `presence_type = 'warehouse'`.

Combine the sets with `UNION`, not `UNION ALL`, so repeated customers in the same country collapse to one `(country, presence_type)` pair. A country that has both customer and warehouse presence should still have two rows because the labels differ.

Return `country` and `presence_type`. Sort the final combined result by both columns ascending.

### 5. Products never ordered

Answer file: [`exercises/05-products-never-ordered.sql`](exercises/05-products-never-ordered.sql)

Return `product_id` and `product_name` for products that never appear in `order_items`, regardless of product lifecycle or order status. Use correlated `NOT EXISTS` and sort by product ID. Testing orders is insufficient—the relationship to a product exists at item level.

### 6. Customers with a large order line

Answer file: [`exercises/06-customers-with-large-lines.sql`](exercises/06-customers-with-large-lines.sql)

Return customers for whom at least one order item has `quantity >= 5`, across all order statuses. Output `customer_id` and `company_name`, sorted by customer ID. Use `EXISTS` with orders joined to items; the outer result must contain each qualifying customer once without `DISTINCT`.

### 7. Active price leaders per category

Answer file: [`exercises/07-category-price-leaders.sql`](exercises/07-category-price-leaders.sql)

Return every active product tied for the highest active-product price in its category. Output `category_name`, `product_id`, `product_name`, and `unit_price`. Compare the product with a correlated `MAX` over active peers; equality intentionally preserves ties. Sort by category name, then product ID.

### 8. Customer countries without a warehouse

Answer file: [`exercises/08-customer-only-countries.sql`](exercises/08-customer-only-countries.sql)

Use `EXCEPT` to return distinct non-`NULL` customer countries that do not appear in `warehouses.country`. The sole column is `country`; sort it ascending. Do not simulate the set difference with a join in this exercise.

### 9. Countries shared by customers and warehouses

Answer file: [`exercises/09-shared-presence-countries.sql`](exercises/09-shared-presence-countries.sql)

Use `INTERSECT` to return distinct country codes present in both non-`NULL` customer countries and warehouse countries. Return one column named `country`, sorted ascending.

### 10. Latest order per customer with `LATERAL`

Answer file: [`exercises/10-latest-order-lateral.sql`](exercises/10-latest-order-lateral.sql)

Return every customer with `customer_id`, `company_name`, `latest_order_id`, `latest_order_date`, and `latest_order_status`. Use `LEFT JOIN LATERAL` to run a correlated order query, sort it by date and order ID descending, and take one row. Customers without orders retain `NULL` order fields. Sort the final output by customer ID.

## Running the checks

```bash
./scripts/check-section.sh 05          # sections 01–05
./scripts/check-section.sh 05 --only   # these four exercises only
```
