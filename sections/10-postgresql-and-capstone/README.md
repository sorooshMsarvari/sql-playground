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

## Running the checks

```bash
# Only the three capstone-section exercises
./scripts/check-section.sh 10 --only

# Every answer from sections 01 through 10
./scripts/check-section.sh 10
```

Passing the cumulative command means all 31 exercises currently satisfy their documented output contracts.

