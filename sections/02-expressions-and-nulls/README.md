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

### `employees` and `products`

Later questions also derive display values from employees and classify catalog products.

| Table | Column | Type | Null? | Meaning |
|---|---|---|---:|---|
| `employees` | `employee_id` | `integer` | No | Primary key |
| `employees` | `first_name` | `text` | No | Given name |
| `employees` | `last_name` | `text` | No | Family name |
| `products` | `product_id` | `integer` | No | Primary key |
| `products` | `product_name` | `text` | No | Catalog name |
| `products` | `unit_price` | `numeric(10,2)` | No | Current price |
| `products` | `discontinued` | `boolean` | No | Active when `false` |

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

### 4. Employee display identifiers

Answer file: [`exercises/04-employee-identifiers.sql`](exercises/04-employee-identifiers.sql)

For every employee, return `employee_id`, `full_name`, `initials`, and `username`. `full_name` is first and last name separated by one space; `initials` is the uppercase first character of each name; `username` is lowercase `first_name.last_name`. Sort by `employee_id`. Do not hard-code any names.

### 5. Calendar parts of 2024 orders

Answer file: [`exercises/05-order-calendar-parts.sql`](exercises/05-order-calendar-parts.sql)

For every order placed in calendar year 2024, return `order_id` plus `order_year`, `order_month`, and `order_quarter` extracted from `order_date` and cast to `integer`. Sort chronologically by the original `order_date`, then `order_id`.

### 6. Normalize optional order notes

Answer file: [`exercises/06-normalized-notes.sql`](exercises/06-normalized-notes.sql)

Return every `order_id` and a `note_text`. Trim leading and trailing whitespace from `notes`; treat an empty trimmed string as missing; display `none` for a missing value. The intended expression order is `BTRIM` → `NULLIF` → `COALESCE`. Sort by `order_id`.

### 7. Active product price bands

Answer file: [`exercises/07-product-price-bands.sql`](exercises/07-product-price-bands.sql)

Classify every active product as `budget` when `unit_price < 50`, `standard` when price is at least 50 but below 150, and `premium` when price is at least 150. Return `product_id`, `product_name`, and `price_band`. Sort by the underlying `unit_price` ascending, then `product_id`.

### 8. Human-readable discounts

Answer file: [`exercises/08-discount-display.sql`](exercises/08-discount-display.sql)

For item rows with a positive discount, return `order_id`, `product_id`, `discount_percent` (`discount * 100`, rounded to one decimal), and `net_unit_price` (`unit_price * (1 - discount)`, rounded to two decimals). Sort by `order_id`, then `product_id`.

### 9. Shipping display values

Answer file: [`exercises/09-shipping-display.sql`](exercises/09-shipping-display.sql)

For every order, return `order_id`, `shipped_on`, and `shipping_state`. Format a present `shipped_at` as `YYYY-MM-DD`; otherwise use the text `not shipped`. `shipping_state` is `shipped` when a date exists and `waiting` otherwise. Sort by `order_id`. Convert the date to text before using `COALESCE` with a text label.

### 10. Customer email domains

Answer file: [`exercises/10-customer-email-domains.sql`](exercises/10-customer-email-domains.sql)

For customers with an email address, return `customer_id`, `company_name`, and the lowercase text after `@` as `email_domain`. Use `split_part`; exclude `NULL` emails. Sort by `email_domain`, then `customer_id`.

## Running the checks

```bash
# Check sections 01 and 02 incrementally
./scripts/check-section.sh 02

# Check only this section
./scripts/check-section.sh 02 --only
```
