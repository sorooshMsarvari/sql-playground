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

### Additional grouping dimensions

| Table | Important columns | Relationship and grain |
|---|---|---|
| `categories` | `category_id` PK, unique `category_name` | One row per product category |
| `products` | `product_id` PK, `category_id` FK, `unit_price`, `discontinued` | Many products belong to one category |
| `employees` | `employee_id` PK, names, `department` | One row per employee; orders reference their sales representative |
| `warehouses` | `warehouse_id` PK, unique `warehouse_name` | One row per stock location |
| `inventory` | composite PK `(warehouse_id, product_id)`, `units_in_stock`, `reorder_level` | One product-stock row per warehouse |

Inventory quantities and reorder levels are nonnegative integers. A location is below threshold only when `units_in_stock < reorder_level`; equality is not below.

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

### 4. 2024 order-status summary

Answer file: [`exercises/04-order-status-summary.sql`](exercises/04-order-status-summary.sql)

For orders placed in 2024, return one row per `status` with `order_count` and `gross_revenue`. Count distinct orders and calculate discounted item revenue even for non-completed statuses; this is a workload summary, not recognized revenue. Round revenue to two decimals and sort by `status`.

### 5. Active-product price statistics by category

Answer file: [`exercises/05-category-price-statistics.sql`](exercises/05-category-price-statistics.sql)

Return every `category_name` with `active_products`, `min_price`, `max_price`, and `average_price` for active products only. Round the average to two decimals. Preserve a category even if it has no active products; its count is zero and price aggregates are `NULL`. Sort by category name.

### 6. Completed performance for every sales employee

Answer file: [`exercises/06-sales-rep-performance.sql`](exercises/06-sales-rep-performance.sql)

Return every employee in the `Sales` department, including managers with no assigned completed order. Output `employee_id`, concatenated `sales_rep`, distinct `completed_orders`, and discounted `completed_revenue` rounded to two decimals. Zero-fill missing metrics. Sort by revenue descending, then employee ID.

### 7. Monthly order-status counts

Answer file: [`exercises/07-monthly-order-status.sql`](exercises/07-monthly-order-status.sql)

For each month represented by an order in 2024, return `month_start` as a date, `total_orders`, `completed_orders`, and `cancelled_orders`. Use aggregate `FILTER` for the status counts and sort chronologically. This question does not require empty months.

### 8. Per-customer status counts

Answer file: [`exercises/08-customer-status-counts.sql`](exercises/08-customer-status-counts.sql)

Return every customer with `customer_id`, `company_name`, `total_orders`, `completed_orders`, and `open_orders`, where open means `pending` or `processing`. Customers without orders must receive zero counts. With a left join, count `o.order_id`, not `COUNT(*)`. Sort by customer ID.

### 9. Product inventory totals

Answer file: [`exercises/09-product-inventory-totals.sql`](exercises/09-product-inventory-totals.sql)

For every product return `product_id`, `product_name`, total `units_in_stock` as `total_stock`, number of inventory rows as `stocked_warehouses`, and count of locations where stock is strictly below reorder level as `below_reorder_locations`. Zero-fill products absent from inventory. Sort by total stock descending, then product ID.

### 10. Warehouse reorder summary

Answer file: [`exercises/10-warehouse-reorder-summary.sql`](exercises/10-warehouse-reorder-summary.sql)

For warehouses with at least one inventory row strictly below its reorder level, return `warehouse_id`, `warehouse_name`, `low_skus`, and `units_short`. `units_short` is the sum of `GREATEST(reorder_level - units_in_stock, 0)` across the warehouse. Use `HAVING` and sort by shortage descending, then warehouse ID.

### 11. Completed sales by category

Answer file: [`exercises/11-category-completed-sales.sql`](exercises/11-category-completed-sales.sql)

Return every category with `category_id`, `category_name`, `completed_units`, and discounted `completed_revenue`. Preserve zero-sale categories with left joins and zero-fill both metrics. Round revenue to two decimals. Sort by revenue descending, then category ID.

### 12. Average completed-order value by segment

Answer file: [`exercises/12-segment-order-value.sql`](exercises/12-segment-order-value.sql)

First aggregate items to one row per completed order. Then group those order totals by customer `segment`. Return `segment`, `completed_orders`, `average_order_value`, and `total_revenue`, with monetary outputs rounded to two decimals. This prevents large orders with many lines from receiving extra weight. Sort by segment.

## Running the checks

```bash
./scripts/check-section.sh 03          # sections 01–03
./scripts/check-section.sh 03 --only   # section 03 only
```
