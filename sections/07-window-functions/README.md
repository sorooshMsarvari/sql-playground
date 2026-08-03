# 07 — Window functions

An aggregate normally collapses multiple input rows into fewer output rows. A window function calculates across related rows while preserving the current row. Its `PARTITION BY`, window `ORDER BY`, and frame answer three different questions: which rows are peers, in what sequence, and which portion of that sequence contributes.

## Schema used in this section

### Product catalog

```text
categories (1) ──< products
```

| Table | Column | Type | Null? | Key or meaning |
|---|---|---|---:|---|
| `categories` | `category_id` | `integer` | No | Primary key |
| `categories` | `category_name` | `text` | No | Unique category name |
| `products` | `product_id` | `integer` | No | Primary key |
| `products` | `product_name` | `text` | No | Product name |
| `products` | `category_id` | `integer` | No | FK → `categories.category_id` |
| `products` | `unit_price` | `numeric(10,2)` | No | Current catalog price |
| `products` | `discontinued` | `boolean` | No | Active when `false` |

### Orders and historical revenue

| Table | Column | Type | Null? | Key or meaning |
|---|---|---|---:|---|
| `orders` | `order_id` | `integer` | No | Primary key |
| `orders` | `customer_id` | `integer` | No | FK → `customers.customer_id` |
| `orders` | `order_date` | `date` | No | Date placed |
| `orders` | `status` | `text` | No | Only `completed` is included in these analytics |
| `order_items` | `order_id` | `integer` | No | FK → `orders.order_id` |
| `order_items` | `quantity` | `integer` | No | Units |
| `order_items` | `unit_price` | `numeric(10,2)` | No | Historical unit price |
| `order_items` | `discount` | `numeric(4,3)` | No | Fractional discount |

Revenue remains `quantity * unit_price * (1 - discount)`.

## Exercises

### 1. Product price rank within category

Answer file: [`exercises/01-price-rank.sql`](exercises/01-price-rank.sql)

Rank active products from most expensive to least expensive inside each category. Return one row per active product.

| Output column | Definition |
|---|---|
| `category_name` | Category display name |
| `product_name` | Product display name |
| `unit_price` | Current catalog price |
| `price_rank` | `DENSE_RANK` within the product's category, ordered by descending price |

Use `DENSE_RANK`, so equal prices share a rank and the next distinct price receives the immediately following rank. Partition by category identity, not by the entire database.

The final display order is separate from the window order: sort by `category_name`, then `price_rank`, then `product_name`, all ascending.

### 2. Monthly and running revenue

Answer file: [`exercises/02-running-revenue.sql`](exercises/02-running-revenue.sql)

For each month that contains at least one completed order in calendar year 2024, show that month's revenue and the cumulative revenue from January through that month.

First create a `monthly` CTE with one row per month and an unrounded revenue total. Then apply a windowed `SUM` to those monthly rows.

| Output column | Definition |
|---|---|
| `month_start` | First date of the order month, as `date` |
| `monthly_revenue` | That month's discounted completed-order revenue, rounded to two decimals |
| `running_revenue` | Sum of monthly revenue from the first row through the current month, rounded to two decimals |

Use an explicit ordered row frame from `UNBOUNDED PRECEDING` through `CURRENT ROW`. Include only months with completed orders; unlike section 06, this exercise does not ask for zero-filled empty months. Sort by `month_start`.

### 3. Time between a customer's completed orders

Answer file: [`exercises/03-order-intervals.sql`](exercises/03-order-intervals.sql)

Create a chronological completed-order timeline independently for each customer.

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `order_id` | Completed order identifier |
| `order_date` | Date placed |
| `previous_order_date` | Date of that customer's immediately preceding completed order |
| `days_since_previous` | Current `order_date - previous_order_date` |

Use `LAG(order_date)` partitioned by `customer_id` and ordered by `order_date`, then `order_id` as a tie-breaker. Calculate the lagged date in a CTE or subquery so it can be reused for subtraction.

For the first completed order in each customer partition, both derived columns must remain SQL `NULL`. Sort the final result by `customer_id`, `order_date`, and `order_id` ascending.

## Running the checks

```bash
./scripts/check-section.sh 07
./scripts/check-section.sh 07 --only
```

