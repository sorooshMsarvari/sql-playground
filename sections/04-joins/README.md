# 04 — Joins and table relationships

A normalized database stores each fact once and connects facts with keys. A join reconstructs a useful view of those facts. Before joining, identify the cardinality—one-to-one, one-to-many, or many-to-many—and decide whether unmatched rows must remain in the output.

## Schema used in this section

```text
customers (1) ──< orders >── (1) employees
products  (1) ──< order_items >── (1) orders
customers (referrer, 1) ──< customers (referred customers)
```

### `orders`

One row represents one order.

| Column | Type | Null? | Relationship or meaning |
|---|---|---:|---|
| `order_id` | `integer` | No | Primary key |
| `customer_id` | `integer` | No | FK → `customers.customer_id` |
| `sales_rep_id` | `integer` | Yes | FK → `employees.employee_id` |
| `order_date` | `date` | No | Date placed |
| `status` | `text` | No | Order lifecycle state |

### `customers`

One row represents one customer.

| Column | Type | Null? | Relationship or meaning |
|---|---|---:|---|
| `customer_id` | `integer` | No | Primary key |
| `company_name` | `text` | No | Company name |
| `referred_by` | `integer` | Yes | Self-FK → another row's `customer_id`; `NULL` means no known referrer |

### `employees`

One row represents one employee.

| Column | Type | Null? | Relationship or meaning |
|---|---|---:|---|
| `employee_id` | `integer` | No | Primary key |
| `first_name` | `text` | No | Given name |
| `last_name` | `text` | No | Family name |
| `manager_id` | `integer` | Yes | Self-FK → `employees.employee_id` |
| `department` | `text` | No | Organizational department |

### `products` and `order_items`

`products` contains one row per catalog product. `order_items` is the bridge from orders to products.

| Table | Column | Type | Null? | Relationship or meaning |
|---|---|---|---:|---|
| `products` | `product_id` | `integer` | No | Primary key |
| `products` | `product_name` | `text` | No | Display name |
| `order_items` | `order_id` | `integer` | No | FK → `orders.order_id`; composite PK part |
| `order_items` | `product_id` | `integer` | No | FK → `products.product_id`; composite PK part |
| `order_items` | `quantity` | `integer` | No | Units on that order line |

Products 16 and 17 have no order items. Product 17 also has no inventory rows, and the Wellness category has no products. Correct outer-join reports must preserve these deliberately seeded edge cases.

### Additional relationships

| Table | Important columns | Relationship and grain |
|---|---|---|
| `categories` | `category_id` PK, `category_name` | One category has many products through `products.category_id` |
| `payments` | `payment_id` PK, `order_id` FK, `paid_at`, `amount`, `method`, `status` | One order can have multiple payment events |
| `warehouses` | `warehouse_id` PK, `warehouse_name`, `country` | One row per warehouse |
| `inventory` | `(warehouse_id, product_id)` PK, `units_in_stock`, `reorder_level` | Bridge between warehouses and products |

Payment status is independent of order status. Inventory existence is also independent for each warehouse/product pair, which is why a generated cross product is needed to find missing pairs.

## Exercises

### 1. Orders with customer and sales-representative names

Answer file: [`exercises/01-order-owners.sql`](exercises/01-order-owners.sql)

List every order placed from `2024-03-01` through `2024-06-30`, regardless of status, together with the customer and assigned sales representative.

| Output column | Definition |
|---|---|
| `order_id` | `orders.order_id` |
| `order_date` | `orders.order_date` |
| `company_name` | Matching `customers.company_name` |
| `sales_rep` | Employee `first_name`, one space, then `last_name` |

Join `orders.customer_id` to `customers.customer_id` and `orders.sales_rep_id` to `employees.employee_id`. Use a half-open date range ending at `2024-07-01`. Sort by `order_date`, then `order_id`, both ascending.

### 2. Completed sales for every product

Answer file: [`exercises/02-product-sales.sql`](exercises/02-product-sales.sql)

Build a product-level unit-sales report using completed orders only. Every product must appear—even a product that was never ordered or appeared only on a non-completed order.

| Output column | Definition |
|---|---|
| `product_id` | Product identifier |
| `product_name` | Product display name |
| `sold_units` | Total `quantity` on completed orders; use numeric zero when there are no completed sales |

Start from `products` and preserve it with left joins to `order_items` and `orders`. Be careful: putting `o.status = 'completed'` in a final `WHERE` clause would reject `NULL` outer-join rows and silently turn the report into an inner join. A filtered aggregate is one suitable approach.

Group by product, then sort by `sold_units` descending and `product_name` ascending.

### 3. Customer referral network

Answer file: [`exercises/03-referral-network.sql`](exercises/03-referral-network.sql)

List every customer and the company that referred it, if known.

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `company_name` | Customer's own company name |
| `referred_by_company` | Referring customer's `company_name`, or SQL `NULL` when `referred_by` is `NULL` |

Use `customers` twice with distinct aliases: once as the customer and once as the potential referrer. Preserve all customer rows with a left self-join. Do not replace the missing referrer with display text. Sort by `customer_id`.

### 4. Inventory shortages with names

Answer file: [`exercises/04-inventory-shortages.sql`](exercises/04-inventory-shortages.sql)

Join `inventory` to `warehouses` and `products`. For rows strictly below reorder level, return `warehouse_name`, `product_name`, `units_in_stock`, `reorder_level`, and `units_short` as reorder level minus current stock. Sort by shortage descending, then warehouse and product name.

### 5. Customer order boundaries

Answer file: [`exercises/05-customer-order-boundaries.sql`](exercises/05-customer-order-boundaries.sql)

Return every customer with `customer_id`, `company_name`, `order_count`, `first_order`, and `last_order` across all statuses. Customers with no orders must have count zero and `NULL` dates. Left join, count `o.order_id`, and sort by customer ID.

### 6. Completed 2025 order-line details

Answer file: [`exercises/06-completed-2025-lines.sql`](exercises/06-completed-2025-lines.sql)

For completed orders placed in 2025, return each line as `order_id`, `company_name`, `product_name`, `quantity`, historical `unit_price`, and `discount`. Join all four required tables. Sort by order ID and product name.

### 7. Successful payments with customer identity

Answer file: [`exercises/07-successful-payments.sql`](exercises/07-successful-payments.sql)

Return successful payment events with `payment_id`, `order_id`, `company_name`, `amount`, and `method`. Filter `payments.status`, not order status. Sort by the underlying `paid_at` and then payment ID.

### 8. Missing active-product inventory pairs

Answer file: [`exercises/08-missing-inventory-pairs.sql`](exercises/08-missing-inventory-pairs.sql)

Generate every warehouse × active-product combination, left join inventory on both keys, and retain combinations with no inventory row. Return `warehouse_id`, `warehouse_name`, `product_id`, and `product_name`, sorted by both IDs. This deliberately uses `CROSS JOIN` followed by an anti-match.

### 9. Managers and direct reports

Answer file: [`exercises/09-manager-direct-reports.sql`](exercises/09-manager-direct-reports.sql)

Self-join employees to return one row per direct reporting relationship: `manager_id`, `manager_name`, `report_id`, and `report_name`. Names are first and last joined by one space. Include only managers who actually have a direct report. Sort by manager ID, then report ID.

### 10. Orders without a successful payment

Answer file: [`exercises/10-orders-without-successful-payment.sql`](exercises/10-orders-without-successful-payment.sql)

Return orders for which no `payments` row with status `succeeded` exists. Output `order_id`, order `status`, and `company_name`. Preserve orders with failed, pending, refunded, or no payments by putting the success condition inside a left join, then anti-match on the payment key. Sort by order ID.

### 11. Active products under every category

Answer file: [`exercises/11-active-products-by-category.sql`](exercises/11-active-products-by-category.sql)

Return all categories and their active products with `category_name`, `product_id`, and `product_name`. Preserve a category even if it has no active products, yielding `NULL` product fields. Put `discontinued = false` in the join condition. Sort by category name, product name, then product ID.

### 12. Domestic shipping matches

Answer file: [`exercises/12-domestic-orders.sql`](exercises/12-domestic-orders.sql)

Find orders shipped to the customer's known home country. Return `order_id`, `company_name`, home `country` aliased as `customer_country`, and `shipping_country`. Exclude customers with a `NULL` country, require equality between the two country columns, and sort by order ID. The fixtures deliberately contain matching rows, so this is a real join result rather than an empty hypothetical case.

## Running the checks

```bash
./scripts/check-section.sh 04          # cumulative through joins
./scripts/check-section.sh 04 --only   # only these three exercises
```
