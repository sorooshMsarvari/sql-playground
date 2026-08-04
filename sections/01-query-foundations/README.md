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

### 4. Active product name and price search

Answer file: [`exercises/04-name-and-price-search.sql`](exercises/04-name-and-price-search.sql)

Search the active catalog by product name and price. One output row must represent one matching product.

| Output column | Definition |
|---|---|
| `product_id` | Product identifier |
| `product_name` | Product display name |
| `unit_price` | Current catalog price |

Requirements:

- Include only products whose `discontinued` value is `false`.
- Require `product_name` to contain the letter `a`, ignoring letter case.
- Include prices from 20 through 150, including both endpoints.
- Use `ILIKE` for the name match.
- Sort by `product_name` ascending, then `product_id` ascending.

Expected edge case: a product priced exactly 20 or 150 qualifies when its name and lifecycle also match.

### 5. Open orders since July 2024

Answer file: [`exercises/05-open-orders.sql`](exercises/05-open-orders.sql)

List open orders placed since the start of July 2024. One output row must represent one matching order.

| Output column | Definition |
|---|---|
| `order_id` | Order identifier |
| `order_date` | Date the order was placed |
| `status` | Current order status |
| `shipping_country` | Destination country code |

Requirements:

- Include orders placed on or after `2024-07-01`.
- Treat only `pending` and `processing` as open for this exercise.
- Use one membership condition for the two allowed status values.
- Sort by `order_date` ascending, then `order_id` ascending.

Expected edge case: completed, cancelled, and refunded orders must remain excluded even when their dates satisfy the range.

### 6. Countries receiving completed orders

Answer file: [`exercises/06-shipping-countries.sql`](exercises/06-shipping-countries.sql)

List the destination countries used by completed orders. One output row must represent one distinct country code.

| Output column | Definition |
|---|---|
| `country` | A completed order's `shipping_country`, renamed to `country` |

Requirements:

- Include only orders whose status is `completed`.
- Remove duplicate country codes with `DISTINCT`, not `GROUP BY`.
- Alias the selected column exactly as `country`.
- Sort by `country` ascending.

Expected edge case: several completed orders shipped to the same country must still produce only one row for that country.

### 7. Second page of active products

Answer file: [`exercises/07-second-product-page.sql`](exercises/07-second-product-page.sql)

Return the second page of the active-product catalog. One output row must represent one active product, and each page contains at most five rows.

| Output column | Definition |
|---|---|
| `product_id` | Product identifier |
| `sku` | Product stock-keeping code |
| `product_name` | Product display name |

Requirements:

- Exclude discontinued products before pagination.
- Sort by `product_id` ascending to make page membership stable.
- Skip the first five matching products.
- Return at most the next five matching products.

Expected edge case: applying the offset before filtering would select the wrong page when discontinued products occur among the early IDs.

### 8. Enterprise and recent midmarket customers

Answer file: [`exercises/08-priority-customer-filter.sql`](exercises/08-priority-customer-filter.sql)

Build a priority-customer list from two different qualifying groups. One output row must represent one qualifying customer.

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `company_name` | Customer company name |
| `segment` | Commercial segment |
| `created_at` | Customer acquisition date |

Requirements:

- Include every `enterprise` customer regardless of acquisition date.
- Also include `midmarket` customers created on or after `2023-01-01`.
- Do not include `smb` customers.
- Parenthesize the midmarket/date branch so the `AND` and `OR` logic is explicit.
- Sort by `segment` ascending, then `customer_id` ascending.

Expected edge case: the date condition applies only to midmarket customers, not to the enterprise branch.

### 9. Non-negative spring orders

Answer file: [`exercises/09-spring-orders.sql`](exercises/09-spring-orders.sql)

Find spring 2024 orders that did not end in a negative lifecycle state. One output row must represent one matching order.

| Output column | Definition |
|---|---|
| `order_id` | Order identifier |
| `order_date` | Date the order was placed |
| `status` | Current order status |

Requirements:

- Include dates from `2024-03-01` through `2024-05-31`, including both endpoints.
- Exclude statuses `cancelled` and `refunded` with `NOT IN`.
- Allow every other status.
- Sort by `order_date` ascending, then `order_id` ascending.

Expected edge case: orders on the first and last dates of the range qualify when their statuses are allowed.

### 10. Recently introduced active catalog items

Answer file: [`exercises/10-recent-catalog.sql`](exercises/10-recent-catalog.sql)

List active catalog items introduced since the start of 2023. One output row must represent one matching product.

| Output column | Definition |
|---|---|
| `catalog_id` | `products.product_id` |
| `name` | `products.product_name` |
| `price` | `products.unit_price` |

Requirements:

- Include only active products created on or after `2023-01-01`.
- Use the exact output aliases `catalog_id`, `name`, and `price`.
- Sort by the underlying `created_at` value descending.
- Break equal creation dates with `product_id` ascending.

Expected edge case: `created_at` controls the order even though it is not returned as an output column.

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
