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

Create reusable display identifiers for every employee. One output row must represent one employee.

| Output column | Definition |
|---|---|
| `employee_id` | Employee identifier |
| `full_name` | `first_name`, one space, then `last_name` |
| `initials` | Uppercase first character of each name, with no separator |
| `username` | Lowercase `first_name.last_name` |

Requirements:

- Derive every display value from the stored name columns.
- Use text concatenation and text functions rather than hard-coding names.
- Keep the exact output aliases shown above.
- Sort by `employee_id` ascending.

Expected edge case: uppercase initials and the lowercase username require separate case conversions.

### 5. Calendar parts of 2024 orders

Answer file: [`exercises/05-order-calendar-parts.sql`](exercises/05-order-calendar-parts.sql)

Break 2024 order dates into calendar components. One output row must represent one order placed during 2024.

| Output column | Definition |
|---|---|
| `order_id` | Order identifier |
| `order_year` | Year extracted from `order_date`, as `integer` |
| `order_month` | Month number extracted from `order_date`, as `integer` |
| `order_quarter` | Quarter number extracted from `order_date`, as `integer` |

Requirements:

- Use a half-open date range from `2024-01-01` through the start of `2025-01-01`.
- Use `EXTRACT` for all three calendar values.
- Cast every extracted value to `integer`.
- Sort by the original `order_date` ascending, then `order_id` ascending.

Expected edge case: the output does not include `order_date`, but chronological ordering must still use it.

### 6. Normalize optional order notes

Answer file: [`exercises/06-normalized-notes.sql`](exercises/06-normalized-notes.sql)

Normalize the optional note for every order. One output row must represent one order, including an order whose note is missing or blank.

| Output column | Definition |
|---|---|
| `order_id` | Order identifier |
| `note_text` | Trimmed note text, or the literal `none` when no content remains |

Requirements:

- Remove leading and trailing whitespace with `BTRIM`.
- Convert an empty trimmed string to `NULL` with `NULLIF`.
- Replace the resulting `NULL` with `none` using `COALESCE`.
- Apply the operations in the order `BTRIM` → `NULLIF` → `COALESCE`.
- Sort by `order_id` ascending.

Expected edge case: a note containing only whitespace must be displayed as `none`, just like a stored `NULL`.

### 7. Active product price bands

Answer file: [`exercises/07-product-price-bands.sql`](exercises/07-product-price-bands.sql)

Classify every active product into a price band. One output row must represent one active product.

| Output column | Definition |
|---|---|
| `product_id` | Product identifier |
| `product_name` | Product display name |
| `price_band` | `budget`, `standard`, or `premium` according to current price |

Requirements:

- `budget`: `unit_price < 50`
- `standard`: `unit_price >= 50` and `unit_price < 150`
- `premium`: `unit_price >= 150`
- Exclude discontinued products.
- Sort by underlying `unit_price` ascending, then `product_id` ascending.

Evaluate the `CASE` conditions from the lowest threshold upward.

Expected edge case: a price of exactly 50 is `standard`, while a price of exactly 150 is `premium`.

### 8. Human-readable discounts

Answer file: [`exercises/08-discount-display.sql`](exercises/08-discount-display.sql)

Display discounts and net prices for discounted order items. One output row must represent one item row whose discount is positive.

| Output column | Definition |
|---|---|
| `order_id` | Parent order identifier |
| `product_id` | Product identifier |
| `discount_percent` | `discount * 100`, rounded to one decimal place |
| `net_unit_price` | `unit_price * (1 - discount)`, rounded to two decimal places |

Requirements:

- Exclude item rows whose discount is zero.
- Convert the stored fractional discount to a percentage before rounding.
- Calculate net price from the historical item `unit_price`.
- Sort by `order_id` ascending, then `product_id` ascending.

Expected edge case: `discount` is a fraction such as `0.100`, not an already formatted percentage.

### 9. Shipping display values

Answer file: [`exercises/09-shipping-display.sql`](exercises/09-shipping-display.sql)

Create shipping display values for every order. One output row must represent one order, whether shipped or not.

| Output column | Definition |
|---|---|
| `order_id` | Order identifier |
| `shipped_on` | Shipping date formatted as `YYYY-MM-DD`, or `not shipped` when absent |
| `shipping_state` | `shipped` when `shipped_at` exists; otherwise `waiting` |

Requirements:

- Convert a present shipping date to text with `TO_CHAR`.
- Use `COALESCE` only after the date has become text.
- Derive `shipping_state` with `CASE` and a `NULL` test.
- Sort by `order_id` ascending.

Expected edge case: SQL cannot directly combine a `date` value and the text label `not shipped` without first formatting the date.

### 10. Customer email domains

Answer file: [`exercises/10-customer-email-domains.sql`](exercises/10-customer-email-domains.sql)

Extract an email domain for every customer who has an email address. One output row must represent one qualifying customer.

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `company_name` | Customer company name |
| `email_domain` | Lowercase text after the `@` separator |

Requirements:

- Exclude customers whose email is `NULL`.
- Use `split_part(email, '@', 2)` to extract the domain portion.
- Normalize the extracted domain with `LOWER`.
- Sort by `email_domain` ascending, then `customer_id` ascending.

Expected edge case: missing emails must be filtered before they can produce meaningless empty domain text.

## Running the checks

```bash
# Check sections 01 and 02 incrementally
./scripts/check-section.sh 02

# Check only this section
./scripts/check-section.sh 02 --only
```
