# 01 — Query foundations

This section teaches the basic shape of a query: choosing columns, filtering rows, combining predicates, sorting deterministically, and limiting a result. Read this page first; the comments in the exercise files are only compact reminders.

## Schema used in this section

All tables are in the `shop` schema. The `sql_student` role already has `shop` on its search path, so `FROM products` and `FROM shop.products` are equivalent.

### `products`

One row represents one product currently or historically present in the catalog.

| Column | Type | Null? | Key or constraint | Meaning |
|---|---|---:|---|---|
| `product_id` | `integer` | No | Primary key, generated identity | Stable product identifier |
| `sku` | `text` | No | Unique | Human-facing stock-keeping code |
| `product_name` | `text` | No |  | Display name |
| `category_id` | `integer` | No | FK → `categories.category_id` | Product category |
| `unit_price` | `numeric(10,2)` | No | Must be at least 0 | Current catalog price |
| `discontinued` | `boolean` | No | Default `false` | Whether the product is no longer active |
| `attributes` | `jsonb` | No | Default `{}` | Flexible product properties; used in section 10 |
| `created_at` | `date` | No |  | Date the catalog record was created |

Important: an “active product” means `discontinued = false`. SQL also supports the shorter boolean predicate `NOT discontinued`.

### `customers`

One row represents one customer company.

| Column | Type | Null? | Key or constraint | Meaning |
|---|---|---:|---|---|
| `customer_id` | `integer` | No | Primary key, generated identity | Stable customer identifier |
| `company_name` | `text` | No |  | Company display name |
| `email` | `text` | Yes | Unique when present | Primary email address |
| `phone` | `text` | Yes |  | Primary telephone number |
| `country` | `text` | Yes |  | Two-letter country code such as `DE` or `FR` |
| `segment` | `text` | No | `smb`, `midmarket`, or `enterprise` | Commercial customer segment |
| `referred_by` | `integer` | Yes | Self-FK → `customers.customer_id` | Customer that made the referral |
| `created_at` | `date` | No |  | Customer acquisition date |
| `metadata` | `jsonb` | No | Default `{}` | Acquisition and priority properties |

### `orders`

One row represents one order. Product lines are stored separately in `order_items`, which is introduced later.

| Column | Type | Null? | Key or constraint | Meaning |
|---|---|---:|---|---|
| `order_id` | `integer` | No | Primary key, generated identity | Stable order identifier |
| `customer_id` | `integer` | No | FK → `customers.customer_id` | Customer that placed the order |
| `sales_rep_id` | `integer` | Yes | FK → `employees.employee_id` | Responsible sales representative |
| `order_date` | `date` | No |  | Date the order was placed |
| `status` | `text` | No | `pending`, `processing`, `completed`, `cancelled`, or `refunded` | Current lifecycle state |
| `shipping_country` | `text` | No |  | Destination country code |
| `shipped_at` | `date` | Yes | Cannot precede `order_date` | Shipping date, if shipped |
| `notes` | `text` | Yes |  | Optional operational note |

## Exercises

### 1. Five most expensive active products

Answer file: [`exercises/01-select-products.sql`](exercises/01-select-products.sql)

The catalog team wants a compact list of the five most expensive products that are still active.

Return exactly these columns, in this order:

| Output column | Source |
|---|---|
| `sku` | `products.sku` |
| `product_name` | `products.product_name` |
| `unit_price` | `products.unit_price` |

Requirements:

- Exclude discontinued products.
- Sort by `unit_price` from highest to lowest.
- If prices tie, sort `sku` alphabetically so the output is deterministic.
- Return only the first five rows after sorting.

Concepts: projection, boolean filtering, multi-column `ORDER BY`, descending order, and `LIMIT`.

### 2. Target-market SMB customers

Answer file: [`exercises/02-filter-customers.sql`](exercises/02-filter-customers.sql)

Marketing needs the older SMB accounts in five target markets. Find customers that satisfy all three conditions:

1. `segment` is `smb`;
2. `country` is one of `FR`, `ES`, `NL`, `AT`, or `FI`;
3. `created_at` is earlier than `2024-01-01`.

Return `customer_id`, `company_name`, and `country`, in that order. Sort first by `country` ascending and then by `company_name` ascending.

Concepts: `AND`, `IN`, comparison with a typed `DATE` literal, and deterministic sorting.

### 3. Most recent completed orders in 2024

Answer file: [`exercises/03-recent-orders.sql`](exercises/03-recent-orders.sql)

Operations wants the five most recent orders that were completed during calendar year 2024.

Return `order_id`, `customer_id`, and `order_date`, in that order.

Requirements:

- Include only rows whose `status` is exactly `completed`.
- Include dates from `2024-01-01` through `2024-12-31`.
- Prefer a half-open date range: `>= 2024-01-01` and `< 2025-01-01`. This pattern also remains correct when a column later changes from `date` to `timestamp`.
- Sort by `order_date` newest first, then by `order_id` highest first.
- Return only five rows.

## Running the checks

Check one answer:

```bash
./scripts/check.sh sections/01-query-foundations/exercises/01-select-products.sql
```

Check the complete section:

```bash
./scripts/check-section.sh 01
```

The checker validates column names, column order, row values, duplicate rows, result order, and row count.

