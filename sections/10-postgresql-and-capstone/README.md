# 10 — PostgreSQL features and capstone analytics

This final section uses PostgreSQL JSONB operators and then combines joins, CTEs, aggregation, missing-value handling, JSON extraction, and window ranking in one report. JSONB is useful for sparse or evolving properties, but stable relational facts and relationships still belong in typed columns and constrained tables.

## Schema used in this section

### `customers`

One row represents one customer company.

| Column | Type | Null? | Key or constraint | Meaning |
|---|---|---:|---|---|
| `customer_id` | `integer` | No | Primary key | Customer identifier |
| `company_name` | `text` | No |  | Company name |
| `segment` | `text` | No | `smb`, `midmarket`, or `enterprise` | Ranking partition |
| `metadata` | `jsonb` | No | Default `{}` | Acquisition properties |

Representative `metadata` values are:

```json
{"channel": "partner", "priority": "high"}
{"channel": "organic", "priority": "medium"}
{"channel": "unknown"}
```

JSON objects are not guaranteed to contain the same keys. In PostgreSQL, `metadata ->> 'channel'` extracts the property as SQL text and returns SQL `NULL` when the key is absent.

### `products`

One row represents one catalog product.

| Column | Type | Null? | Key or constraint | Meaning |
|---|---|---:|---|---|
| `product_id` | `integer` | No | Primary key | Product identifier |
| `product_name` | `text` | No |  | Product name |
| `discontinued` | `boolean` | No | Default `false` | Active-product flag |
| `attributes` | `jsonb` | No | Default `{}` | Product-specific properties |

Example `attributes` objects:

```json
{"color": "black", "wireless": true, "warranty_years": 3}
{"color": "gray", "ports": 8, "warranty_years": 1}
{"color": "blue", "pages": 192}
```

The containment predicate `attributes @> '{"wireless":true}'::jsonb` checks that a JSON object contains that exact key/value pair. The text extraction operator `->>` must be cast when the output contract requires an integer.

### Orders and revenue

```text
customers (1) ──< orders (1) ──< order_items
```

| Table | Column | Type | Null? | Key or meaning |
|---|---|---|---:|---|
| `orders` | `order_id` | `integer` | No | Primary key |
| `orders` | `customer_id` | `integer` | No | FK → `customers.customer_id` |
| `orders` | `order_date` | `date` | No | Date placed |
| `orders` | `status` | `text` | No | Only `completed` contributes to the capstone |
| `order_items` | `order_id` | `integer` | No | FK → `orders.order_id` |
| `order_items` | `quantity` | `integer` | No | Units |
| `order_items` | `unit_price` | `numeric(10,2)` | No | Historical unit price |
| `order_items` | `discount` | `numeric(4,3)` | No | Fractional discount |

### Payments and inventory

| Table | Important columns | Relationship and grain |
|---|---|---|
| `categories` | `category_id` PK, `category_name` | Product grouping dimension |
| `payments` | `payment_id` PK, `order_id` FK, `amount`, `method`, `status` | One payment event; an order can have several |
| `warehouses` | `warehouse_id` PK, `warehouse_name` | One location per row |
| `inventory` | `(warehouse_id, product_id)` PK, `units_in_stock`, `reorder_level` | One product/location pair |

The inventory capstone joins `inventory.product_id` to products and `inventory.warehouse_id` to warehouses. Its total-stock window must run before low-stock locations are filtered.

## Exercises

### 1. High-priority partner customers

Answer file: [`exercises/01-json-customer-channels.sql`](exercises/01-json-customer-channels.sql)

Find customers whose JSON metadata contains both:

- `channel` equal to the text `partner`;
- `priority` equal to the text `high`.

Return:

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `company_name` | Company name |
| `channel` | Text extracted from `metadata.channel` |
| `priority` | Text extracted from `metadata.priority` |

Use `->>` so the selected and compared values are SQL text, not JSON strings. Sort by `customer_id` ascending. Customers missing either key do not match.

### 2. Wireless products and warranty length

Answer file: [`exercises/02-json-product-features.sql`](exercises/02-json-product-features.sql)

Find active products whose `attributes` JSON explicitly contains `wireless: true`.

| Output column | Definition |
|---|---|
| `product_name` | Product display name |
| `warranty_years` | `attributes.warranty_years`, extracted and cast to SQL `integer` |

Requirements:

- Exclude discontinued products.
- Use JSONB containment (`@>`) to test the boolean value `true`; do not compare it to the text string `"true"`.
- Extract warranty years with `->>` and cast it to `integer`.
- Sort by `warranty_years` descending and then `product_name` ascending.

Only products that explicitly declare wireless capability qualify. A missing `wireless` property is not equivalent to `false`, but it does not satisfy the containment predicate.

### 3. Segment revenue leaderboard — capstone

Answer file: [`exercises/03-segment-leaderboard.sql`](exercises/03-segment-leaderboard.sql)

Rank customers by completed-order lifetime revenue within their own commercial segment, and return ranks 1 and 2 from each segment.

Build the query in three CTE stages:

1. `order_totals`: one row per completed order with `order_id`, `customer_id`, `order_date`, and unrounded discounted revenue.
2. `customer_metrics`: one row per customer that has at least one completed order, with identity, segment, acquisition channel, order count, revenue, and first/last completed-order dates.
3. `ranked`: add a `DENSE_RANK` partitioned by `segment` and ordered by unrounded `lifetime_revenue` descending.

Return exactly these columns:

| Output column | Definition |
|---|---|
| `segment` | Customer segment |
| `revenue_rank` | Dense revenue rank inside that segment |
| `customer_id` | Customer identifier |
| `company_name` | Company name |
| `acquisition_channel` | Text from `metadata.channel`, or `unknown` if that key is missing |
| `completed_orders` | Number of completed orders, counted after the order-level aggregation |
| `lifetime_revenue` | Sum of completed-order revenue, rounded to two decimals for display |
| `first_order` | Earliest completed order date |
| `last_order` | Latest completed order date |

Important semantics:

- Customers without completed orders are excluded, rather than displayed with zero revenue.
- Rank within each segment independently.
- Use `DENSE_RANK`, so a tie can produce more than two returned customers for a segment.
- Rank using the unrounded revenue value; round only the final displayed amount.
- Filter window results in an outer query or CTE because a window result is not available to the same query level's `WHERE` clause.
- Keep only `revenue_rank <= 2`.
- Sort by `segment`, `revenue_rank`, and `customer_id`, all ascending.

### 4. Active products as ordered JSON arrays

Answer file: [`exercises/04-category-products-json.sql`](exercises/04-category-products-json.sql)

Build one JSONB product array for each category that has an active product. One output row must represent one such category.

| Output column | Definition |
|---|---|
| `category_name` | Category name |
| `products` | Ordered JSONB array of active-product objects |

Every object in `products` must contain:

| JSON key | Source value |
|---|---|
| `product_id` | Product identifier |
| `name` | Product name |
| `price` | Current unit price |

Use `jsonb_build_object` for each product and `jsonb_agg` for the category array. Exclude discontinued products. Order objects inside each aggregate by product name ascending, then product ID ascending, and sort category rows by `category_name` ascending.

Expected edge case: ordering the outer rows does not determine element order inside a JSON aggregate; the aggregate needs its own ordering.

### 5. Latest order with PostgreSQL `DISTINCT ON`

Answer file: [`exercises/05-latest-order-distinct-on.sql`](exercises/05-latest-order-distinct-on.sql)

Return the newest order for every customer who has placed an order. One output row must represent one such customer.

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `company_name` | Customer company name |
| `order_id` | Newest order identifier |
| `order_date` | Newest order date |
| `status` | Newest order status |

Requirements:

- Join customers to orders and use PostgreSQL `DISTINCT ON (customer_id)`.
- Begin `ORDER BY` with the same customer key required by `DISTINCT ON`.
- Follow it with `order_date` descending and `order_id` descending.
- Exclude customers without orders naturally through the inner join.

Expected edge case: the descending order-ID tie-breaker determines which order survives when dates tie.

### 6. Successful-payment method pivot

Answer file: [`exercises/06-payment-method-pivot.sql`](exercises/06-payment-method-pivot.sql)

Pivot successful payment amounts into one row per order that has at least one successful payment.

| Output column | Definition |
|---|---|
| `order_id` | Related order identifier |
| `card_total` | Successful card amount, or zero, rounded to two decimals |
| `bank_transfer_total` | Successful bank-transfer amount, or zero, rounded to two decimals |
| `paypal_total` | Successful PayPal amount, or zero, rounded to two decimals |

Requirements:

- Filter input rows to payment status `succeeded` before grouping.
- Group by `order_id`.
- Use a separate aggregate `FILTER` for each payment method.
- Convert a missing method total to zero and round every displayed total to two decimals.
- Sort by `order_id` ascending.

Expected edge case: an order with successful payments in only one method still requires zeroes in the other two output columns.

### 7. Quarterly completed revenue

Answer file: [`exercises/07-quarterly-revenue.sql`](exercises/07-quarterly-revenue.sql)

Summarize completed-order activity by represented quarter in 2024. One output row must represent one quarter containing a completed order.

| Output column | Definition |
|---|---|
| `quarter_start` | First date of the quarter, returned as `date` |
| `completed_orders` | Number of distinct completed orders in the quarter |
| `revenue` | Discounted item revenue for those orders, rounded to two decimals |

Requirements:

- Include completed orders from `2024-01-01` through the start of `2025-01-01`.
- Join orders to their item rows and calculate historical discounted revenue.
- Derive the grouping value with `date_trunc('quarter', order_date)` and cast it to `date`.
- Count distinct order IDs because joining items multiplies order rows.
- Do not generate quarters without completed orders.
- Sort by `quarter_start` ascending.

Expected edge case: counting joined item rows would overstate the number of completed orders.

### 8. Inventory risk capstone

Answer file: [`exercises/08-inventory-risk-capstone.sql`](exercises/08-inventory-risk-capstone.sql)

Report low-stock active-product locations while retaining company-wide product stock totals. One output row must represent one inventory location below its reorder threshold.

| Output column | Definition |
|---|---|
| `warehouse_name` | Warehouse name |
| `category_name` | Product category name |
| `product_name` | Product name |
| `product_color` | Text from `attributes.color`, or `unknown` when absent |
| `units_in_stock` | Units at the current location |
| `reorder_level` | Threshold at the current location |
| `units_short` | `reorder_level - units_in_stock` |
| `product_total_stock` | Product's units summed across all warehouse inventory rows |

Requirements:

- In a CTE, join inventory to warehouses, active products, and categories.
- Extract color with `->>` and replace a missing key with `unknown`.
- Compute `SUM(units_in_stock) OVER (PARTITION BY product_id)` inside that CTE.
- Only in the outer query keep rows where `units_in_stock < reorder_level`.
- Calculate `units_short` from the current location values.
- Sort by `units_short` descending, then `warehouse_name` and `product_name` ascending.

Expected edge case: filtering to low locations before the window calculation would omit healthy locations from `product_total_stock` and produce an incorrect company-wide total.

## Running the checks

```bash
# Only section 10
./scripts/check-section.sh 10 --only

# Every answer from sections 01 through 10
./scripts/check-section.sh 10
```

Passing the cumulative command means all 100 exercises currently satisfy their documented output contracts.
