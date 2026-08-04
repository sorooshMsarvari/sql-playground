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

Summarize the 2024 order workload by lifecycle status. One output row must represent one status that occurs during 2024.

| Output column | Definition |
|---|---|
| `status` | Stored order status |
| `order_count` | Number of distinct orders with that status |
| `gross_revenue` | Sum of discounted item revenue for those orders, rounded to two decimals |

Requirements:

- Include orders placed on or after `2024-01-01` and before `2025-01-01`.
- Join each order to its item rows and use `quantity * unit_price * (1 - discount)` for line revenue.
- Count distinct order IDs because one order can have several item rows after the join.
- Include every represented status, not only `completed`; this is a workload summary rather than recognized revenue.
- Sort by `status` ascending.

Expected edge case: joining order items multiplies order rows, so counting joined rows would overstate `order_count`.

### 5. Active-product price statistics by category

Answer file: [`exercises/05-category-price-statistics.sql`](exercises/05-category-price-statistics.sql)

Calculate active-product price statistics for every category. One output row must represent one category, including a category with no active products.

| Output column | Definition |
|---|---|
| `category_name` | Category name |
| `active_products` | Number of products whose `discontinued` value is `false` |
| `min_price` | Lowest active-product `unit_price`, or `NULL` when none exists |
| `max_price` | Highest active-product `unit_price`, or `NULL` when none exists |
| `average_price` | Average active-product price rounded to two decimals, or `NULL` when none exists |

Requirements:

- Start from `categories` so every category can be preserved.
- Match only active products while retaining a category that has no match.
- Count a product identifier rather than all joined rows so an unmatched category receives zero.
- Let `MIN`, `MAX`, and `AVG` ignore the missing product values naturally.
- Sort by `category_name` ascending.

Expected edge case: filtering active products after the left join would remove categories with no active product.

### 6. Completed performance for every sales employee

Answer file: [`exercises/06-sales-rep-performance.sql`](exercises/06-sales-rep-performance.sql)

Report completed-order performance for every employee in the `Sales` department. One output row must represent one sales employee, including a manager or representative with no completed order.

| Output column | Definition |
|---|---|
| `employee_id` | Employee identifier |
| `sales_rep` | `first_name` and `last_name` joined with one space |
| `completed_orders` | Number of distinct completed orders assigned to the employee |
| `completed_revenue` | Discounted item revenue from those orders, rounded to two decimals |

Requirements:

- Exclude employees outside the `Sales` department.
- Preserve Sales employees who have no assigned completed order.
- Count distinct orders because joining order items produces several rows for a multi-line order.
- Use `quantity * unit_price * (1 - discount)` for revenue.
- Return zero for both metrics when an employee has no completed order.
- Sort by `completed_revenue` descending, then `employee_id` ascending.

Expected edge case: placing the completed-status condition where it removes unmatched rows would lose Sales employees with no completed order.

### 7. Monthly order-status counts

Answer file: [`exercises/07-monthly-order-status.sql`](exercises/07-monthly-order-status.sql)

Summarize order counts for each represented month in 2024. One output row must represent one month that contains at least one order.

| Output column | Definition |
|---|---|
| `month_start` | First day of the order month, returned as a `date` |
| `total_orders` | Number of orders in the month, regardless of status |
| `completed_orders` | Number of monthly orders whose status is `completed` |
| `cancelled_orders` | Number of monthly orders whose status is `cancelled` |

Requirements:

- Include orders placed on or after `2024-01-01` and before `2025-01-01`.
- Use `date_trunc` to derive the monthly grouping value and cast it to `date`.
- Use aggregate `FILTER` clauses for the two status-specific counts.
- Do not generate months that have no order; that is handled in a later section.
- Sort by `month_start` ascending.

Expected edge case: `total_orders` includes completed, cancelled, and every other order status.

### 8. Per-customer status counts

Answer file: [`exercises/08-customer-status-counts.sql`](exercises/08-customer-status-counts.sql)

Count orders by status for every customer. One output row must represent one customer, including a customer who has never placed an order.

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `company_name` | Customer company name |
| `total_orders` | Number of all orders placed by the customer |
| `completed_orders` | Number of orders whose status is `completed` |
| `open_orders` | Number of orders whose status is `pending` or `processing` |

Requirements:

- Start from `customers` and preserve customers without matching orders.
- Use aggregate `FILTER` clauses for the completed and open counts.
- Count `orders.order_id`, not all joined rows, so an unmatched customer receives zero.
- Group by the customer identity and name.
- Sort by `customer_id` ascending.

Expected edge case: the placeholder row created by a left join must not be counted as an order.

### 9. Product inventory totals

Answer file: [`exercises/09-product-inventory-totals.sql`](exercises/09-product-inventory-totals.sql)

Summarize warehouse inventory for every product. One output row must represent one product, including a product absent from all inventory rows.

| Output column | Definition |
|---|---|
| `product_id` | Product identifier |
| `product_name` | Product name |
| `total_stock` | Sum of `units_in_stock` across all warehouses |
| `stocked_warehouses` | Number of inventory rows for the product |
| `below_reorder_locations` | Number of locations where stock is strictly below the reorder level |

Requirements:

- Start from `products` and preserve products without inventory rows.
- Treat a product with no inventory as having zero total stock and zero warehouse counts.
- A location is below its threshold only when `units_in_stock < reorder_level`; equality does not count.
- Count an inventory key rather than all joined rows.
- Sort by `total_stock` descending, then `product_id` ascending.

Expected edge case: `SUM` over no matched inventory values produces `NULL`, which must become zero.

### 10. Warehouse reorder summary

Answer file: [`exercises/10-warehouse-reorder-summary.sql`](exercises/10-warehouse-reorder-summary.sql)

Report the reorder workload for warehouses that have at least one low-stock product. One output row must represent one affected warehouse.

| Output column | Definition |
|---|---|
| `warehouse_id` | Warehouse identifier |
| `warehouse_name` | Warehouse name |
| `low_skus` | Number of inventory rows strictly below their reorder level |
| `units_short` | Total units required to bring low-stock rows up to their reorder levels |

Requirements:

- Join warehouses to their inventory rows and group by warehouse identity and name.
- A row is low only when `units_in_stock < reorder_level`.
- Calculate each row's shortage as `GREATEST(reorder_level - units_in_stock, 0)` before summing.
- Use `HAVING` to remove warehouse groups whose low-SKU count is zero.
- Sort by `units_short` descending, then `warehouse_id` ascending.

Expected edge case: inventory at or above its reorder level contributes zero to `units_short`.

### 11. Completed sales by category

Answer file: [`exercises/11-category-completed-sales.sql`](exercises/11-category-completed-sales.sql)

Summarize completed sales for every product category. One output row must represent one category, including a category with no completed sales.

| Output column | Definition |
|---|---|
| `category_id` | Category identifier |
| `category_name` | Category name |
| `completed_units` | Sum of item quantities from completed orders |
| `completed_revenue` | Discounted item revenue from completed orders, rounded to two decimals |

Requirements:

- Follow categories to products, order items, and orders while preserving categories with no matching completed sale.
- Include historical sales from both active and discontinued products.
- Apply the completed-status condition to both sales aggregates without removing zero-sale categories.
- Use `quantity * unit_price * (1 - discount)` for revenue.
- Return zero for both metrics when a category has no completed sale.
- Sort by `completed_revenue` descending, then `category_id` ascending.

Expected edge case: filtering completed orders as an ordinary final row filter would remove categories that need zero-valued results.

### 12. Average completed-order value by segment

Answer file: [`exercises/12-segment-order-value.sql`](exercises/12-segment-order-value.sql)

Compare completed-order value across customer segments. The final result must contain one row per segment represented by at least one completed order.

| Output column | Definition |
|---|---|
| `segment` | Customer segment: `smb`, `midmarket`, or `enterprise` |
| `completed_orders` | Number of completed orders placed by customers in the segment |
| `average_order_value` | Average of the completed order totals, rounded to two decimals |
| `total_revenue` | Sum of the completed order totals, rounded to two decimals |

Requirements:

- First create one intermediate row per completed order by summing its discounted item revenue.
- Keep `customer_id` with each order total so the order can be associated with its customer's segment.
- Count and average the order-level rows only after that first aggregation.
- Give every order equal weight in `average_order_value`, regardless of how many item rows it contains.
- Sort by `segment` ascending.

Expected edge case: averaging raw item rows would give multi-line orders more influence than single-line orders.

## Running the checks

```bash
./scripts/check-section.sh 03          # sections 01–03
./scripts/check-section.sh 03 --only   # section 03 only
```
