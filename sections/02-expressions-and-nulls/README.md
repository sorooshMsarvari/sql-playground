# 02 — Expressions, NULLs, text, and dates

This section turns stored values into useful information. You will calculate money, label missing data, classify rows with `CASE`, and perform date arithmetic. SQL `NULL` means “unknown or missing”; it is not an empty string, zero, or a value that can be compared with `= NULL`.

## Schema used in this section

### `order_items`

One row represents one product line on one order. Its composite primary key prevents the same product from appearing twice on the same order.

| Column | Type | Null? | Key or constraint | Meaning |
|---|---|---:|---|---|
| `order_id` | `integer` | No | PK part, FK → `orders.order_id`, cascades on order deletion | Parent order |
| `product_id` | `integer` | No | PK part, FK → `products.product_id` | Product sold |
| `quantity` | `integer` | No | Greater than 0 | Number of units |
| `unit_price` | `numeric(10,2)` | No | At least 0 | Historical price charged per unit |
| `discount` | `numeric(4,3)` | No | From `0` through `1`; default `0` | Fractional discount, so `0.100` means 10% |

Use `order_items.unit_price`, not `products.unit_price`, when calculating historical revenue. The line-total formula is:

```text
quantity × unit_price × (1 − discount)
```

### `customers`

One row represents one customer. The columns relevant here are:

| Column | Type | Null? | Meaning |
|---|---|---:|---|
| `customer_id` | `integer` | No | Primary key |
| `company_name` | `text` | No | Company display name |
| `email` | `text` | Yes | Email address; customer 14 has no email |
| `phone` | `text` | Yes | Phone number; several customers have no phone |

### `orders`

One row represents one order.

| Column | Type | Null? | Meaning |
|---|---|---:|---|
| `order_id` | `integer` | No | Primary key |
| `order_date` | `date` | No | Date placed |
| `status` | `text` | No | `pending`, `processing`, `completed`, `cancelled`, or `refunded` |
| `shipped_at` | `date` | Yes | Shipping date; `NULL` for an order that has not shipped |

Subtracting one PostgreSQL `date` from another produces an integer number of days. Any arithmetic involving a `NULL` operand produces `NULL`.

## Exercises

### 1. Discounted line totals

Answer file: [`exercises/01-line-totals.sql`](exercises/01-line-totals.sql)

Calculate the monetary total of every item line belonging to orders 1001, 1002, 1003, or 1004.

Return these columns:

| Output column | Definition |
|---|---|
| `order_id` | Parent order identifier |
| `product_id` | Product identifier |
| `quantity` | Units on the line |
| `line_total` | `quantity * unit_price * (1 - discount)`, rounded to two decimal places |

Sort by `order_id` ascending and then `product_id` ascending. The endpoints 1001 and 1004 are included.

Do not round the operands separately; calculate the complete expression and round the final numeric result.

### 2. Customer contact-quality report

Answer file: [`exercises/02-null-handling.sql`](exercises/02-null-handling.sql)

Return one row for every customer, even when contact information is missing.

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `company_name` | Company name |
| `contact_email` | The stored `email`, or the literal text `missing` when `email` is `NULL` |
| `phone_status` | `available` when `phone` is present; otherwise `missing` |

Sort by `customer_id` ascending. Use `COALESCE` for the email and `CASE` with `IS NULL` or `IS NOT NULL` for the phone. Do not use `email = NULL` or `phone <> NULL`; those comparisons evaluate to unknown.

### 3. Order lifecycle and fulfillment time

Answer file: [`exercises/03-order-lifecycle.sql`](exercises/03-order-lifecycle.sql)

Classify every order placed from `2024-04-01` through `2024-06-30` inclusive.

| Output column | Definition |
|---|---|
| `order_id` | Order identifier |
| `order_date` | Date placed |
| `fulfillment_days` | `shipped_at - order_date`; leave it `NULL` when the order has no shipping date |
| `lifecycle` | `closed` for `completed`, `refunded`, or `cancelled`; `open` for every other status |

Use a half-open range ending at `2024-07-01`. Sort by `order_date` ascending and then `order_id` ascending. Let SQL preserve a missing shipping date naturally; do not replace it with zero.

## Running the checks

```bash
# Check sections 01 and 02 incrementally
./scripts/check-section.sh 02

# Check only this section
./scripts/check-section.sh 02 --only
```

