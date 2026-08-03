# 03 — Aggregation and grouping

Aggregation changes the grain of a result. A detail table may contain one row per item, while an aggregate query can produce one row per order, customer, country, or status. Before writing SQL, complete this sentence: “One output row represents one ___.”

## Schema used in this section

The relevant relationship chain is:

```text
customers (one) ──< orders (many) ──< order_items (many)
```

### `customers`

One row represents one customer company.

| Column | Type | Null? | Key or constraint | Meaning |
|---|---|---:|---|---|
| `customer_id` | `integer` | No | Primary key | Customer identifier |
| `company_name` | `text` | No |  | Company name |
| `country` | `text` | Yes |  | Two-letter country code; customer 14 has no country |
| `segment` | `text` | No | `smb`, `midmarket`, or `enterprise` | Commercial segment |

### `orders`

One row represents one order.

| Column | Type | Null? | Key or constraint | Meaning |
|---|---|---:|---|---|
| `order_id` | `integer` | No | Primary key | Order identifier |
| `customer_id` | `integer` | No | FK → `customers.customer_id` | Customer that placed the order |
| `order_date` | `date` | No |  | Date placed |
| `status` | `text` | No | Five allowed lifecycle values | Only `completed` contributes to completed revenue |

### `order_items`

One row represents one product line on one order.

| Column | Type | Null? | Key or constraint | Meaning |
|---|---|---:|---|---|
| `order_id` | `integer` | No | Composite PK, FK → `orders.order_id` | Parent order |
| `product_id` | `integer` | No | Composite PK, FK → `products.product_id` | Product on the line |
| `quantity` | `integer` | No | Greater than 0 | Units sold; sum this for a unit count |
| `unit_price` | `numeric(10,2)` | No | At least 0 | Historical price charged |
| `discount` | `numeric(4,3)` | No | Between 0 and 1 | Fractional discount |

Revenue for an item row is `quantity * unit_price * (1 - discount)`. `COUNT(*)` counts rows; it does not count the units stored inside `quantity`.

## Exercises

### 1. Customers per country

Answer file: [`exercises/01-customer-counts.sql`](exercises/01-customer-counts.sql)

Create a country-level customer count. One output row must represent one country bucket.

| Output column | Definition |
|---|---|
| `country` | Stored country code, except a `NULL` country must appear as `Unknown` |
| `customer_count` | Number of customer rows in that bucket |

Group using the same `COALESCE` expression that you select. Sort by `customer_count` descending, then `country` ascending to resolve ties.

Expected edge case: the customer with no country must be counted, not discarded.

### 2. Completed-order totals

Answer file: [`exercises/02-completed-order-totals.sql`](exercises/02-completed-order-totals.sql)

Summarize every completed order. One output row must represent one order, even though an order has several item rows.

| Output column | Definition |
|---|---|
| `order_id` | Completed order identifier |
| `revenue` | Sum of discounted line totals, rounded to two decimals after summing |
| `units` | Sum of `order_items.quantity` across the order |

Requirements:

- Join `orders` to `order_items` using `order_id`.
- Exclude every order whose status is not `completed` before grouping.
- Do not use `COUNT(*)` for `units`—that would count different product lines rather than units.
- Sort by `revenue` descending and then `order_id` ascending.

### 3. High-value customers

Answer file: [`exercises/03-high-value-customers.sql`](exercises/03-high-value-customers.sql)

Find customers whose total revenue from completed orders is strictly greater than 1500.

Return:

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `company_name` | Customer company name |
| `completed_revenue` | Total discounted item revenue from completed orders, rounded to two decimals |

Join customers → orders → order items. Group by the customer identity and name. Use `WHERE` to remove non-completed input rows and `HAVING` to remove customer groups at or below the threshold. A customer whose revenue is exactly 1500 must not be returned.

Sort by `completed_revenue` descending, then `customer_id` ascending.

## Running the checks

```bash
./scripts/check-section.sh 03          # sections 01–03
./scripts/check-section.sh 03 --only   # section 03 only
```
