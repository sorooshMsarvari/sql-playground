# 06 — CTEs, recursion, and generated series

A common table expression (CTE) gives a name to an intermediate result. Use it to make the grain of each stage explicit. A recursive CTE repeatedly feeds prior rows into a recursive branch, while a generated date series creates rows that do not yet exist in business tables—for example, months with no orders.

## Schema used in this section

### Commerce relationship

```text
customers (1) ──< orders (1) ──< order_items
```

| Table | Column | Type | Null? | Key or meaning |
|---|---|---|---:|---|
| `customers` | `customer_id` | `integer` | No | Primary key |
| `customers` | `company_name` | `text` | No | Company name |
| `orders` | `order_id` | `integer` | No | Primary key |
| `orders` | `customer_id` | `integer` | No | FK → `customers.customer_id` |
| `orders` | `order_date` | `date` | No | Date placed |
| `orders` | `status` | `text` | No | Lifecycle state |
| `order_items` | `order_id` | `integer` | No | FK → `orders.order_id` |
| `order_items` | `quantity` | `integer` | No | Units |
| `order_items` | `unit_price` | `numeric(10,2)` | No | Historical unit price |
| `order_items` | `discount` | `numeric(4,3)` | No | Fractional discount |

Customers 13 and 14 have no orders. Reports that promise “every customer” must preserve them with an outer join.

### `employees`

One row represents one employee. `manager_id` points back into the same table, creating a hierarchy.

| Column | Type | Null? | Key or constraint | Meaning |
|---|---|---:|---|---|
| `employee_id` | `integer` | No | Primary key | Employee identifier |
| `first_name` | `text` | No |  | Given name |
| `last_name` | `text` | No |  | Family name |
| `manager_id` | `integer` | Yes | Self-FK → `employees.employee_id` | Direct manager; `NULL` for the root |
| `department` | `text` | No |  | Department |
| `hire_date` | `date` | No |  | Employment start date |
| `salary` | `numeric(10,2)` | No | Greater than 0 | Current salary |

Employee 1 is the root used by the exercise. Managers have multiple direct reports, and the deepest employees are two reporting edges below employee 1.

### Catalog and inventory inputs

| Table | Important columns | Relationship and grain |
|---|---|---|
| `categories` | `category_id` PK, `category_name` | One category per row |
| `products` | `product_id` PK, `category_id` FK, `product_name`, `discontinued` | One product per row |
| `inventory` | `(warehouse_id, product_id)` PK, `units_in_stock`, `reorder_level` | One product at one warehouse |

The stock-risk exercise aggregates inventory across locations before classifying a product. The category-share exercise joins categories through products and items to completed orders.

## Exercises

### 1. Customer lifetime summary with named stages

Answer file: [`exercises/01-customer-lifetime.sql`](exercises/01-customer-lifetime.sql)

Build a completed-order lifetime report for every customer, including customers with no completed orders.

Use at least these logical stages:

1. An `order_totals` CTE with one row per completed order. It should contain the order's customer, date, and discounted item revenue.
2. A customer-level aggregate of `order_totals` with counts, summed revenue, and date boundaries.
3. An outer query that left-joins those metrics to all customers.

Return:

| Output column | Definition for customers with orders | Definition for customers without completed orders |
|---|---|---|
| `customer_id` | Customer identifier | Customer identifier |
| `company_name` | Company name | Company name |
| `completed_orders` | Number of completed orders | Numeric `0` |
| `lifetime_revenue` | Sum of order revenue, rounded to two decimals | Numeric `0.00`/`0` |
| `first_order` | Earliest completed `order_date` | SQL `NULL` |
| `last_order` | Latest completed `order_date` | SQL `NULL` |

Sort by `lifetime_revenue` descending and then `customer_id` ascending. Count orders only after item rows have been collapsed to one row per order; otherwise `COUNT(*)` counts item lines.

### 2. Recursive organization tree

Answer file: [`exercises/02-organization-tree.sql`](exercises/02-organization-tree.sql)

Starting at employee 1, return that employee and every direct or indirect report reachable through `manager_id`.

Your `WITH RECURSIVE` query needs:

- An anchor branch selecting employee 1 at depth 0.
- A recursive branch joining a child employee's `manager_id` to an employee already found by the CTE.
- `UNION ALL` between the two branches.

Return:

| Output column | Definition |
|---|---|
| `employee_id` | Employee identifier |
| `employee_name` | `first_name`, one space, then `last_name` |
| `depth` | Root = 0, direct report = 1, next level = 2 |
| `reporting_path` | Names from root to current employee joined with ` > ` |

For example, the shape of a level-two path is `Root Name > Manager Name > Employee Name`. Sort alphabetically by the complete `reporting_path`; do not sort only by depth.

### 3. Complete monthly calendar for 2024

Answer file: [`exercises/03-monthly-calendar.sql`](exercises/03-monthly-calendar.sql)

Produce exactly twelve rows—one for the first day of every month in 2024—even if a month has no completed orders.

Use `generate_series` to create month starts from `2024-01-01` to `2024-12-01` at one-month intervals. Cast each generated value to `date`, then left join completed orders and their items.

| Output column | Definition |
|---|---|
| `month_start` | First calendar date of the month, as `date` |
| `completed_orders` | Distinct completed orders placed during that month; zero for an empty month |
| `revenue` | Discounted item revenue from those orders, rounded to two decimals; zero for an empty month |

Put order-status and date-range predicates in the join condition so an empty generated month is not removed by `WHERE`. Sort by `month_start` ascending.

### 4. Product stock risk in staged CTEs

Answer file: [`exercises/04-product-stock-risk.sql`](exercises/04-product-stock-risk.sql)

Classify company-wide stock risk for every active product. One output row must represent one active product, including a product absent from inventory.

| Output column | Definition |
|---|---|
| `product_id` | Product identifier |
| `product_name` | Product display name |
| `total_stock` | Sum of `units_in_stock` across all locations, or zero when absent |
| `total_reorder_level` | Sum of `reorder_level` across all locations, or zero when absent |
| `stock_state` | `at risk` when total stock is lower than the total threshold; otherwise `sufficient` |

Required stages:

1. A `stock_totals` CTE that starts from active products, preserves missing inventory, and calculates both totals.
2. A second CTE that classifies each aggregated product.
3. A final query that returns the five required columns.

Sort by `stock_state` ascending, then `product_id` ascending.

Expected edge case: an active product with no inventory has two zero totals and is therefore `sufficient`, because zero is not less than zero.

### 5. Recursive customer referral tree

Answer file: [`exercises/05-referral-tree.sql`](exercises/05-referral-tree.sql)

Starting at customer 1, return every customer reachable through the referral hierarchy. One output row must represent one customer in that tree.

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `company_name` | Customer company name |
| `depth` | Root = 0, direct referral = 1, next level = 2 |
| `referral_path` | Company names from the root to the current customer, joined with ` > ` |

Requirements:

- Use `WITH RECURSIVE` with customer 1 as the anchor row.
- In the recursive branch, match a child's `referred_by` to a customer already in the CTE.
- Increase `depth` by one for each referral edge.
- Extend the parent's path with the child company name.
- Combine anchor and recursive branches with `UNION ALL`.
- Sort by the complete `referral_path` ascending.

Expected edge case: customers outside customer 1's referral descendants must not appear.

### 6. Daily January calendar

Answer file: [`exercises/06-january-daily-orders.sql`](exercises/06-january-daily-orders.sql)

Create a complete daily order calendar for January 2024. One output row must represent one calendar date, whether or not an order exists.

| Output column | Definition |
|---|---|
| `calendar_date` | Date from `2024-01-01` through `2024-01-31` |
| `total_orders` | Number of orders placed on that date |
| `completed_orders` | Number of those orders whose status is `completed` |

Requirements:

- Generate all 31 dates with `generate_series` at one-day intervals and cast them to `date`.
- Left join orders by exact `order_date` so empty dates survive.
- Count `orders.order_id`, not every joined row, for the total.
- Use aggregate `FILTER` for the completed count.
- Sort by `calendar_date` ascending.

Expected edge case: a date without an order must return zero for both counts, not disappear.

### 7. Completed revenue share by category

Answer file: [`exercises/07-category-revenue-share.sql`](exercises/07-category-revenue-share.sql)

Calculate each selling category's share of completed-order revenue. One output row must represent one category with completed sales.

| Output column | Definition |
|---|---|
| `category_name` | Category name |
| `category_revenue` | Category's discounted completed-order revenue, rounded to two decimals |
| `revenue_percent` | `100 * category revenue / grand total`, rounded to two decimals |

Required stages:

1. A `category_revenue` CTE that joins categories through products and items to completed orders and returns one unrounded revenue total per category.
2. A one-row `grand_total` CTE that sums those category totals.
3. A final query that combines each category with the grand total and calculates its percentage.

Sort by `category_revenue` descending, then `category_name` ascending.

Expected edge case: calculate percentages from unrounded category totals and round only the displayed results.

### 8. Customer completed-order activity buckets

Answer file: [`exercises/08-customer-activity-buckets.sql`](exercises/08-customer-activity-buckets.sql)

Group every customer by completed-order activity, then count customers in each group. One final output row must represent one represented activity bucket.

| Output column | Definition |
|---|---|
| `activity_bucket` | `none`, `one`, or `repeat` |
| `customer_count` | Number of customers assigned to that bucket |

Bucket rules:

- `none`: zero completed orders
- `one`: exactly one completed order
- `repeat`: two or more completed orders

First count completed orders for every customer, preserving customers without orders. Classify those customer-level rows in a second stage, then group the classified rows by bucket. Display buckets in semantic order: `none`, `one`, `repeat`.

Expected edge case: counting all order statuses would incorrectly classify customers whose only orders are not completed.

## Running the checks

```bash
./scripts/check-section.sh 06
./scripts/check-section.sh 06 --only
```
