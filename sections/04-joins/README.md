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

Product 16 has no order items. A correct outer-join report must preserve it.

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

## Running the checks

```bash
./scripts/check-section.sh 04          # cumulative through joins
./scripts/check-section.sh 04 --only   # only these three exercises
```

