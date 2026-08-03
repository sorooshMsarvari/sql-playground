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

For every active product, first aggregate all inventory rows into `total_stock` and `total_reorder_level`, zero-filling products absent from inventory. In a second CTE classify the row as `at risk` when total stock is below total reorder level, otherwise `sufficient`. Return `product_id`, `product_name`, both totals, and `stock_state`. Sort by state, then product ID.

### 5. Recursive customer referral tree

Answer file: [`exercises/05-referral-tree.sql`](exercises/05-referral-tree.sql)

Starting at customer 1, recursively follow rows whose `referred_by` points to a customer already found. Return `customer_id`, `company_name`, `depth` (root 0), and `referral_path` with company names joined by ` > `. Use `UNION ALL` and sort by complete path.

### 6. Daily January calendar

Answer file: [`exercises/06-january-daily-orders.sql`](exercises/06-january-daily-orders.sql)

Generate all 31 dates from `2024-01-01` through `2024-01-31`. Return `calendar_date`, `total_orders`, and `completed_orders`, including zeroes on dates with no orders. Left join orders by exact date, count `o.order_id`, use `FILTER` for completed count, and sort chronologically.

### 7. Completed revenue share by category

Answer file: [`exercises/07-category-revenue-share.sql`](exercises/07-category-revenue-share.sql)

Build a `category_revenue` CTE from completed discounted sales and a one-row `grand_total` CTE. Return `category_name`, revenue rounded as `category_revenue`, and `revenue_percent = 100 * category revenue / grand total`, rounded to two decimals. Sort by category revenue descending, then name.

### 8. Customer completed-order activity buckets

Answer file: [`exercises/08-customer-activity-buckets.sql`](exercises/08-customer-activity-buckets.sql)

Count completed orders for every customer, classify the customer as `none`, `one`, or `repeat` (two or more), then count customers in each class. Return `activity_bucket` and `customer_count`. Display buckets in semantic order: none, one, repeat.

## Running the checks

```bash
./scripts/check-section.sh 06
./scripts/check-section.sh 06 --only
```
