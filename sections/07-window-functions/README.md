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

### 4. Latest order using `ROW_NUMBER`

Answer file: [`exercises/04-latest-order-row-number.sql`](exercises/04-latest-order-row-number.sql)

Return the latest order for each customer who has placed an order. One output row must represent one such customer.

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `company_name` | Customer company name |
| `order_id` | Latest order identifier |
| `order_date` | Latest order date |
| `status` | Latest order status |

Requirements:

- Rank orders independently within each `customer_id` partition.
- Use `ROW_NUMBER` ordered by `order_date` descending and `order_id` descending.
- Keep only row number 1, then join the matching customer name.
- Exclude customers without orders.
- Sort the final result by `customer_id` ascending.

Expected edge case: the descending order-ID tie-breaker chooses one deterministic latest row when dates tie.

### 5. Two most expensive active products per category

Answer file: [`exercises/05-top-two-products.sql`](exercises/05-top-two-products.sql)

Return at most two most expensive active products from each represented category. One output row must represent one selected product.

| Output column | Definition |
|---|---|
| `category_name` | Category name |
| `product_id` | Product identifier |
| `product_name` | Product display name |
| `unit_price` | Current catalog price |
| `row_number` | Position 1 or 2 inside the category |

Requirements:

- Exclude discontinued products before ranking.
- Partition `ROW_NUMBER` by category identity.
- Order each partition by `unit_price` descending, then `product_id` ascending.
- Keep rows whose generated number is 1 or 2.
- Sort the final result by `category_name` ascending, then `row_number` ascending.

Expected edge case: equal prices do not create ties with `ROW_NUMBER`; the smaller product ID wins the earlier position.

### 6. Completed-order share of revenue

Answer file: [`exercises/06-order-revenue-percent.sql`](exercises/06-order-revenue-percent.sql)

Calculate each completed order's share of all completed-order revenue. One output row must represent one completed order.

| Output column | Definition |
|---|---|
| `order_id` | Completed order identifier |
| `revenue` | Discounted order total, rounded to two decimals |
| `revenue_percent` | `100 * order revenue / all completed revenue`, rounded to two decimals |

Requirements:

- First aggregate item rows to one unrounded revenue value per completed order.
- Use `quantity * unit_price * (1 - discount)` for line revenue.
- Use `SUM(revenue) OVER ()` as the denominator across all order-level rows.
- Round only the displayed revenue and percentage.
- Sort by `revenue_percent` descending, then `order_id` ascending.

Expected edge case: applying the window denominator to raw item rows would measure line share rather than order share.

### 7. Three-month moving revenue average

Answer file: [`exercises/07-three-month-moving-average.sql`](exercises/07-three-month-moving-average.sql)

Calculate a three-row moving average of monthly completed revenue during 2024. One output row must represent one month containing completed revenue.

| Output column | Definition |
|---|---|
| `month_start` | First date of the represented month |
| `monthly_revenue` | Discounted completed revenue for that month, rounded to two decimals |
| `moving_average_3m` | Average of the current and two preceding monthly rows, rounded to two decimals |

Requirements:

- First aggregate completed orders from calendar year 2024 to one unrounded revenue total per represented month.
- Apply `AVG` over rows ordered by `month_start`.
- Use the explicit frame `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`.
- Do not generate empty months for this exercise.
- Sort by `month_start` ascending.

Expected edge case: the first and second rows average only the monthly rows available so far.

### 8. Customer value quartiles

Answer file: [`exercises/08-customer-value-quartiles.sql`](exercises/08-customer-value-quartiles.sql)

Divide customers with completed orders into four value buckets. One output row must represent one qualifying customer.

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `company_name` | Customer company name |
| `lifetime_revenue` | Discounted completed-order revenue, rounded to two decimals |
| `value_quartile` | `NTILE(4)` bucket; bucket 1 contains the highest-value rows |

Requirements:

- First aggregate unrounded lifetime revenue per customer using completed orders only.
- Exclude customers without completed orders.
- Apply `NTILE(4)` ordered by revenue descending, then `customer_id` ascending.
- Use the customer ID tie-breaker to make bucket assignment deterministic.
- Sort by `value_quartile` ascending, revenue descending, then `customer_id` ascending.

Expected edge case: `NTILE` divides rows as evenly as possible; it does not preserve equal-revenue customers in the same bucket.

### 9. Most and least expensive product on every product row

Answer file: [`exercises/09-category-price-extremes.sql`](exercises/09-category-price-extremes.sql)

Annotate every active product with the most and least expensive active product in its category. One output row must represent one active product.

| Output column | Definition |
|---|---|
| `category_name` | Category name |
| `product_name` | Current row's product name |
| `unit_price` | Current row's product price |
| `most_expensive_product` | First product in the category's descending-price window |
| `least_expensive_product` | Last product in that complete category window |

Requirements:

- Exclude discontinued products.
- Partition both value functions by category identity.
- Order by `unit_price` descending, then `product_id` ascending to resolve ties.
- Use `FIRST_VALUE` for the most expensive name.
- Give `LAST_VALUE` a frame ending at `UNBOUNDED FOLLOWING` so it can see the entire partition.
- Sort by `category_name` ascending, `unit_price` descending, then `product_id` ascending.

Expected edge case: the default frame for `LAST_VALUE` ends at the current row and would produce the wrong least-expensive name.

### 10. Running completed units by product

Answer file: [`exercises/10-product-running-units.sql`](exercises/10-product-running-units.sql)

Calculate cumulative completed units independently for each product. One output row must represent one product line from a completed order.

| Output column | Definition |
|---|---|
| `product_id` | Product identifier |
| `order_id` | Completed order identifier |
| `order_date` | Date of the completed order |
| `quantity` | Units on the current item row |
| `cumulative_units` | Sum of that product's quantities through the current order row |

Requirements:

- Join order items to orders and include only completed orders.
- Partition the windowed sum by `product_id`.
- Order each partition by `order_date` ascending, then `order_id` ascending.
- Use `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`.
- Display rows in the same product/date/order sequence.

Expected edge case: the running total must restart for each product.

### 11. Days until the next completed order

Answer file: [`exercises/11-next-completed-order.sql`](exercises/11-next-completed-order.sql)

Show the time from each completed order to the customer's next completed order. One output row must represent one completed order.

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `order_id` | Completed order identifier |
| `order_date` | Current completed-order date |
| `next_order_date` | Date of the customer's next completed order |
| `days_until_next` | `next_order_date - order_date` |

Requirements:

- Filter to completed orders before calculating the window.
- Use `LEAD(order_date)` partitioned by customer.
- Order by `order_date` ascending, then `order_id` ascending.
- Calculate the next date in a CTE or subquery before using it in subtraction.
- Sort by `customer_id`, `order_date`, and `order_id`, all ascending.

Expected edge case: the final completed order in each customer partition must retain `NULL` for both derived values.

### 12. Product price percent rank

Answer file: [`exercises/12-category-price-percent-rank.sql`](exercises/12-category-price-percent-rank.sql)

Calculate each active product's relative price position inside its category. One output row must represent one active product.

| Output column | Definition |
|---|---|
| `category_name` | Category name |
| `product_name` | Product display name |
| `unit_price` | Current catalog price |
| `price_percent_rank` | Category percent rank multiplied by 100 and rounded to two decimals |

Requirements:

- Exclude discontinued products.
- Partition `PERCENT_RANK` by category identity.
- Order the window by `unit_price` ascending.
- Multiply the rank by 100, cast it to `numeric`, and round to two decimals.
- Sort by `category_name`, `unit_price`, and `product_name`, all ascending.

Expected edge case: equal prices share the same percent rank; the cheapest rank is 0 and the highest distinct price approaches or reaches 100.

## Running the checks

```bash
./scripts/check-section.sh 07
./scripts/check-section.sh 07 --only
```
