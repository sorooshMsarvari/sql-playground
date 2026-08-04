# 04 — Joins and table relationships

A normalized database stores each fact once and connects facts with keys. A join reconstructs a useful view of those facts. Before joining, identify the cardinality—one-to-one, one-to-many, or many-to-many—and decide whether unmatched rows must remain in the output.

## Schema used in this section

```text
customers (1) ──< orders >── (1) employees
products  (1) ──< order_items >── (1) orders
customers (referrer, 1) ──< customers (referred customers)
```

### `orders`

One row represents one order.

| Column | Type | Null? | Relationship or meaning |
|---|---|---:|---|
| `order_id` | `integer` | No | Primary key |
| `customer_id` | `integer` | No | FK → `customers.customer_id` |
| `sales_rep_id` | `integer` | Yes | FK → `employees.employee_id` |
| `order_date` | `date` | No | Date placed |
| `status` | `text` | No | Order lifecycle state |

### `customers`

One row represents one customer.

| Column | Type | Null? | Relationship or meaning |
|---|---|---:|---|
| `customer_id` | `integer` | No | Primary key |
| `company_name` | `text` | No | Company name |
| `referred_by` | `integer` | Yes | Self-FK → another row's `customer_id`; `NULL` means no known referrer |

### `employees`

One row represents one employee.

| Column | Type | Null? | Relationship or meaning |
|---|---|---:|---|
| `employee_id` | `integer` | No | Primary key |
| `first_name` | `text` | No | Given name |
| `last_name` | `text` | No | Family name |
| `manager_id` | `integer` | Yes | Self-FK → `employees.employee_id` |
| `department` | `text` | No | Organizational department |

### `products` and `order_items`

`products` contains one row per catalog product. `order_items` is the bridge from orders to products.

| Table | Column | Type | Null? | Relationship or meaning |
|---|---|---|---:|---|
| `products` | `product_id` | `integer` | No | Primary key |
| `products` | `product_name` | `text` | No | Display name |
| `order_items` | `order_id` | `integer` | No | FK → `orders.order_id`; composite PK part |
| `order_items` | `product_id` | `integer` | No | FK → `products.product_id`; composite PK part |
| `order_items` | `quantity` | `integer` | No | Units on that order line |

Products 16 and 17 have no order items. Product 17 also has no inventory rows, and the Wellness category has no products. Correct outer-join reports must preserve these deliberately seeded edge cases.

### Additional relationships

| Table | Important columns | Relationship and grain |
|---|---|---|
| `categories` | `category_id` PK, `category_name` | One category has many products through `products.category_id` |
| `payments` | `payment_id` PK, `order_id` FK, `paid_at`, `amount`, `method`, `status` | One order can have multiple payment events |
| `warehouses` | `warehouse_id` PK, `warehouse_name`, `country` | One row per warehouse |
| `inventory` | `(warehouse_id, product_id)` PK, `units_in_stock`, `reorder_level` | Bridge between warehouses and products |

Payment status is independent of order status. Inventory existence is also independent for each warehouse/product pair, which is why a generated cross product is needed to find missing pairs.

## Exercises

### 1. Orders with customer and sales-representative names

Answer file: [`exercises/01-order-owners.sql`](exercises/01-order-owners.sql)

List every order placed from `2024-03-01` through `2024-06-30`, regardless of status, together with the customer and assigned sales representative.

| Output column | Definition |
|---|---|
| `order_id` | `orders.order_id` |
| `order_date` | `orders.order_date` |
| `company_name` | Matching `customers.company_name` |
| `sales_rep` | Employee `first_name`, one space, then `last_name` |

Join `orders.customer_id` to `customers.customer_id` and `orders.sales_rep_id` to `employees.employee_id`. Use a half-open date range ending at `2024-07-01`. Sort by `order_date`, then `order_id`, both ascending.

### 2. Completed sales for every product

Answer file: [`exercises/02-product-sales.sql`](exercises/02-product-sales.sql)

Build a product-level unit-sales report using completed orders only. Every product must appear—even a product that was never ordered or appeared only on a non-completed order.

| Output column | Definition |
|---|---|
| `product_id` | Product identifier |
| `product_name` | Product display name |
| `sold_units` | Total `quantity` on completed orders; use numeric zero when there are no completed sales |

Start from `products` and preserve it with left joins to `order_items` and `orders`. Be careful: putting `o.status = 'completed'` in a final `WHERE` clause would reject `NULL` outer-join rows and silently turn the report into an inner join. A filtered aggregate is one suitable approach.

Group by product, then sort by `sold_units` descending and `product_name` ascending.

### 3. Customer referral network

Answer file: [`exercises/03-referral-network.sql`](exercises/03-referral-network.sql)

List every customer and the company that referred it, if known.

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `company_name` | Customer's own company name |
| `referred_by_company` | Referring customer's `company_name`, or SQL `NULL` when `referred_by` is `NULL` |

Use `customers` twice with distinct aliases: once as the customer and once as the potential referrer. Preserve all customer rows with a left self-join. Do not replace the missing referrer with display text. Sort by `customer_id`.

### 4. Inventory shortages with names

Answer file: [`exercises/04-inventory-shortages.sql`](exercises/04-inventory-shortages.sql)

Add warehouse and product names to every low-stock inventory row. One output row must represent one product at one warehouse whose stock is below its threshold.

| Output column | Definition |
|---|---|
| `warehouse_name` | Name of the matching warehouse |
| `product_name` | Name of the matching product |
| `units_in_stock` | Current units at that location |
| `reorder_level` | Replenishment threshold at that location |
| `units_short` | `reorder_level - units_in_stock` |

Requirements:

- Join `inventory` to `warehouses` by `warehouse_id` and to `products` by `product_id`.
- Include only rows where `units_in_stock < reorder_level`.
- Calculate shortage from the values on the same inventory row.
- Sort by `units_short` descending, then `warehouse_name` and `product_name` ascending.

Expected edge case: inventory exactly at its reorder level is not a shortage.

### 5. Customer order boundaries

Answer file: [`exercises/05-customer-order-boundaries.sql`](exercises/05-customer-order-boundaries.sql)

Summarize the complete order history of every customer. One output row must represent one customer, including a customer with no orders.

| Output column | Definition |
|---|---|
| `customer_id` | Customer identifier |
| `company_name` | Customer company name |
| `order_count` | Number of orders across all statuses |
| `first_order` | Earliest order date, or `NULL` when no order exists |
| `last_order` | Latest order date, or `NULL` when no order exists |

Requirements:

- Start from `customers` and preserve unmatched rows with a left join to `orders`.
- Do not filter by order status.
- Count `orders.order_id`, not every joined row.
- Use `MIN` and `MAX` for the date boundaries.
- Sort by `customer_id` ascending.

Expected edge case: a customer without orders must have count zero rather than one placeholder row.

### 6. Completed 2025 order-line details

Answer file: [`exercises/06-completed-2025-lines.sql`](exercises/06-completed-2025-lines.sql)

List item-level details for completed orders placed during 2025. One output row must represent one product line on one qualifying order.

| Output column | Definition |
|---|---|
| `order_id` | Parent order identifier |
| `company_name` | Company that placed the order |
| `product_name` | Product on the item row |
| `quantity` | Units sold on the item row |
| `unit_price` | Historical price stored on `order_items` |
| `discount` | Fractional item discount |

Requirements:

- Join orders to customers, order items, and products through their foreign keys.
- Include only orders whose status is `completed`.
- Use a half-open date range from `2025-01-01` through the start of `2026-01-01`.
- Use `order_items.unit_price`, not the current product catalog price.
- Sort by `order_id` ascending, then `product_name` ascending.

Expected edge case: a multi-line order must produce one row for each item rather than one aggregated order row.

### 7. Successful payments with customer identity

Answer file: [`exercises/07-successful-payments.sql`](exercises/07-successful-payments.sql)

Attach order and customer identity to every successful payment event. One output row must represent one qualifying payment row.

| Output column | Definition |
|---|---|
| `payment_id` | Payment-event identifier |
| `order_id` | Related order identifier |
| `company_name` | Company that placed the related order |
| `amount` | Payment-event amount |
| `method` | Payment method |

Requirements:

- Join payments to orders by `order_id`, then orders to customers by `customer_id`.
- Include only payment rows whose own status is `succeeded`.
- Do not use order status as a substitute for payment status.
- Sort by the underlying `paid_at` ascending, then `payment_id` ascending.

Expected edge case: an order's lifecycle status and a payment event's status are independent facts.

### 8. Missing active-product inventory pairs

Answer file: [`exercises/08-missing-inventory-pairs.sql`](exercises/08-missing-inventory-pairs.sql)

Find active products that have no inventory row at a warehouse. One output row must represent one missing warehouse/product pair.

| Output column | Definition |
|---|---|
| `warehouse_id` | Warehouse identifier |
| `warehouse_name` | Warehouse name |
| `product_id` | Active product identifier |
| `product_name` | Active product name |

Requirements:

- Generate every possible warehouse × product combination with `CROSS JOIN`.
- Limit the candidate products to those whose `discontinued` value is `false`.
- Left join `inventory` using both `warehouse_id` and `product_id`.
- Keep only combinations for which the inventory match is absent.
- Sort by `warehouse_id` ascending, then `product_id` ascending.

Expected edge case: checking only one inventory key would confuse a product stocked at another warehouse with a present pair.

### 9. Managers and direct reports

Answer file: [`exercises/09-manager-direct-reports.sql`](exercises/09-manager-direct-reports.sql)

List every direct manager/report relationship. One output row must represent one employee and that employee's immediate manager.

| Output column | Definition |
|---|---|
| `manager_id` | Manager's employee identifier |
| `manager_name` | Manager's first and last names separated by one space |
| `report_id` | Direct report's employee identifier |
| `report_name` | Direct report's first and last names separated by one space |

Requirements:

- Use `employees` twice with separate manager and report aliases.
- Match `report.manager_id` to the manager's `employee_id`.
- Include only managers who actually have at least one direct report.
- Do not include indirect reporting relationships.
- Sort by `manager_id` ascending, then `report_id` ascending.

Expected edge case: an employee two levels below a manager is not that manager's direct report.

### 10. Orders without a successful payment

Answer file: [`exercises/10-orders-without-successful-payment.sql`](exercises/10-orders-without-successful-payment.sql)

Find orders that have no successful payment event. One output row must represent one qualifying order.

| Output column | Definition |
|---|---|
| `order_id` | Order identifier |
| `status` | Order lifecycle status |
| `company_name` | Company that placed the order |

Requirements:

- Join orders to customers for the company name.
- Left join only payment rows whose status is `succeeded`.
- Keep orders whose successful-payment match is absent by testing the payment key for `NULL`.
- Preserve orders that have only failed, pending, or refunded payments, as well as orders with no payments.
- Sort by `order_id` ascending.

Expected edge case: filtering payment status in a final `WHERE` clause would not implement the required anti-match.

### 11. Active products under every category

Answer file: [`exercises/11-active-products-by-category.sql`](exercises/11-active-products-by-category.sql)

List active products under every category. One output row must represent one category/product match, while a category with no active products must still produce one row.

| Output column | Definition |
|---|---|
| `category_name` | Category name |
| `product_id` | Active product identifier, or `NULL` when none exists |
| `product_name` | Active product name, or `NULL` when none exists |

Requirements:

- Start from `categories` and left join products by `category_id`.
- Put the active-product condition in the join condition.
- Preserve categories with no products and categories whose products are all discontinued.
- Sort by `category_name`, then `product_name`, then `product_id`, all ascending.

Expected edge case: moving the active condition into `WHERE` would remove the deliberately empty category.

### 12. Domestic shipping matches

Answer file: [`exercises/12-domestic-orders.sql`](exercises/12-domestic-orders.sql)

Find orders shipped to the customer's known home country. One output row must represent one domestic-shipping order.

| Output column | Definition |
|---|---|
| `order_id` | Order identifier |
| `company_name` | Customer company name |
| `customer_country` | Customer's stored `country` using this exact alias |
| `shipping_country` | Order destination country |

Requirements:

- Join orders to customers by `customer_id`.
- Exclude customers whose stored country is `NULL`.
- Require customer country and shipping country to be equal.
- Use the exact alias `customer_country`.
- Sort by `order_id` ascending.

Expected edge case: an unknown customer country must not be treated as matching any shipping destination.

## Running the checks

```bash
./scripts/check-section.sh 04          # cumulative through joins
./scripts/check-section.sh 04 --only   # only section 04
```
