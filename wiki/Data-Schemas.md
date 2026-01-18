# Data Schemas

Complete schema reference for all source tables.

---

## Overview

This package manages two source databases representing different upstream business systems:

| Database | Purpose | Tables | Business Domain |
|----------|---------|--------|-----------------|
| **jaffle_shop** | E-commerce/ERP system | 5 tables | Customers, products, orders, payments |
| **jaffle_crm** | Marketing/CRM system | 3 tables | Campaigns, email tracking, web analytics |

**Total**: 8 tables across 2 databases

---

## Database: jaffle_shop

E-commerce and order management system with transactional data.

### jaffle_shop Entity-Relationship Diagram

![jaffle_shop ERD](images/jaffle-shop-erd.svg)

### Tables Overview

| Table | Purpose | Baseline Rows | Pattern |
|-------|---------|---------------|---------|
| **customers** | Customer master data | 100 | Slowly changing dimension (SCD) |
| **products** | Product catalog | 20 | Slowly changing dimension (SCD) |
| **orders** | Order headers | 500 | Transactional, status updates |
| **order_items** | Order line items | 1200 | Transactional, append-only |
| **payments** | Payment records | 0 | Transactional, append-only |

---

### Table: customers

Customer master data with soft delete pattern.

#### Schema

```sql
CREATE TABLE jaffle_shop.customers (
    customer_id   INTEGER PRIMARY KEY,
    first_name    VARCHAR(50),
    last_name     VARCHAR(50),
    email         VARCHAR(100),
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at    TIMESTAMP  -- NULL = active, non-NULL = soft deleted
);
```

#### Columns

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `customer_id` | INTEGER | NOT NULL | Primary key, unique customer identifier |
| `first_name` | VARCHAR(50) | YES | Customer's first name |
| `last_name` | VARCHAR(50) | YES | Customer's last name |
| `email` | VARCHAR(100) | YES | Customer's email address |
| `created_at` | TIMESTAMP | NOT NULL | When customer record was created |
| `updated_at` | TIMESTAMP | NOT NULL | When customer record was last modified |
| `deleted_at` | TIMESTAMP | YES | Soft delete timestamp (NULL = active) |

#### ID Ranges

| State | Row Count | ID Range | Notes |
|-------|-----------|----------|-------|
| **Baseline** | 100 | 1-100 | Initial customers |
| **After Day 1** | 125 | 1-125 | +25 new customers |
| **After Day 2** | 147 | 1-147 | +22 new customers |
| **After Day 3** | 175 | 1-175 | +28 new customers |
| **Custom Data** | varies | 5000+ | User-added test data |

#### Soft Delete Pattern

- **Active customers**: `deleted_at IS NULL`
- **Deleted customers**: `deleted_at IS NOT NULL`

**Example**:
```sql
-- Active customers only
SELECT * FROM jaffle_shop.customers WHERE deleted_at IS NULL;

-- Deleted customers
SELECT * FROM jaffle_shop.customers WHERE deleted_at IS NOT NULL;
```

#### Sample Data

```
customer_id | first_name | last_name | email                        | deleted_at
------------|------------|-----------|------------------------------|------------
1           | Brian      | Alvarez   | brian.alvarez1@example.com   | NULL
2           | Kevin      | Baker     | kevin.baker2@example.com     | NULL
50          | Ashley     | Watson    | ashley.watson50@example.com  | 2024-01-15
```

---

### Table: products

Product catalog with soft delete pattern (discontinued products).

#### Schema

```sql
CREATE TABLE jaffle_shop.products (
    product_id    INTEGER PRIMARY KEY,
    name          VARCHAR(100),
    category      VARCHAR(50),
    price         DECIMAL(10,2),
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at    TIMESTAMP  -- NULL = active, non-NULL = discontinued
);
```

#### Columns

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `product_id` | INTEGER | NOT NULL | Primary key, unique product identifier |
| `name` | VARCHAR(100) | YES | Product name |
| `category` | VARCHAR(50) | YES | Product category (Electronics, Furniture, etc.) |
| `price` | DECIMAL(10,2) | YES | Current product price |
| `created_at` | TIMESTAMP | NOT NULL | When product was added to catalog |
| `updated_at` | TIMESTAMP | NOT NULL | When product was last modified |
| `deleted_at` | TIMESTAMP | YES | Soft delete timestamp (NULL = active, non-NULL = discontinued) |

#### ID Ranges

| State | Row Count | ID Range | Notes |
|-------|-----------|----------|-------|
| **Baseline** | 20 | 1-20 | Initial product catalog |
| **After Day 1** | 20 | 1-20 | No new products |
| **After Day 2** | 20 | 1-20 | Price updates only |
| **After Day 3** | 20 | 1-20 | No new products |
| **Custom Data** | varies | 5000+ | User-added test products |

#### Product Categories

- **Electronics**: Laptop, Mouse, Keyboard, Monitor, Tablet, etc.
- **Furniture**: Chair, Desk, Bookshelf
- **Office**: Lamp, Whiteboard
- **Stationery**: Notebooks, Pens
- **Accessories**: Phone Stand, Cable Organizer, Desk Mat
- **Decor**: Plant Pot, Wall Art

#### Sample Data

```
product_id | name              | category    | price   | deleted_at
-----------|-------------------|-------------|---------|------------
1          | Laptop Pro        | Electronics | 1299.99 | NULL
2          | Wireless Mouse    | Electronics | 29.99   | NULL
7          | Office Chair      | Furniture   | 249.99  | NULL
10         | Notebook Pack     | Stationery  | 12.99   | NULL
```

---

### Table: orders

Order headers with status tracking.

#### Schema

```sql
CREATE TABLE jaffle_shop.orders (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER,
    order_date    DATE,
    status        VARCHAR(20),
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at    TIMESTAMP,  -- NULL = active, non-NULL = cancelled/deleted
    FOREIGN KEY (customer_id) REFERENCES jaffle_shop.customers(customer_id)
);
```

#### Columns

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `order_id` | INTEGER | NOT NULL | Primary key, unique order identifier |
| `customer_id` | INTEGER | YES | Foreign key to customers table |
| `order_date` | DATE | YES | Date order was placed |
| `status` | VARCHAR(20) | YES | Order status (pending, completed, shipped, cancelled) |
| `created_at` | TIMESTAMP | NOT NULL | When order record was created |
| `updated_at` | TIMESTAMP | NOT NULL | When order was last modified |
| `deleted_at` | TIMESTAMP | YES | Soft delete timestamp (NULL = active) |

#### ID Ranges

| State | Row Count | ID Range | Notes |
|-------|-----------|----------|-------|
| **Baseline** | 500 | 1-500 | Initial orders |
| **After Day 1** | 560 | 1-560 | +60 new orders |
| **After Day 2** | 615 | 1-615 | +55 new orders |
| **After Day 3** | 680 | 1-680 | +65 new orders |
| **Custom Data** | varies | 5000+ | User-added test orders |

#### Foreign Keys

- `customer_id` → `customers.customer_id`

#### Order Status Values

- **pending**: Order placed, awaiting processing
- **completed**: Order fulfilled and delivered
- **shipped**: Order shipped, in transit
- **cancelled**: Order cancelled

**Status Transitions**: Deltas update orders from `pending` → `completed` or `shipped` after payments are recorded.

#### Sample Data

```
order_id | customer_id | order_date | status    | created_at
---------|-------------|------------|-----------|-------------------
1        | 82          | 2024-01-15 | pending   | 2024-01-15 10:00
2        | 36          | 2024-01-02 | completed | 2024-01-02 14:30
500      | 18          | 2024-01-20 | completed | 2024-01-20 09:15
```

---

### Table: order_items

Order line items (products within orders).

#### Schema

```sql
CREATE TABLE jaffle_shop.order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id      INTEGER,
    product_id    INTEGER,
    quantity      INTEGER,
    unit_price    DECIMAL(10,2),
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at    TIMESTAMP,  -- Rarely used (line items typically immutable)
    FOREIGN KEY (order_id) REFERENCES jaffle_shop.orders(order_id),
    FOREIGN KEY (product_id) REFERENCES jaffle_shop.products(product_id)
);
```

#### Columns

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `order_item_id` | INTEGER | NOT NULL | Primary key, unique line item identifier |
| `order_id` | INTEGER | YES | Foreign key to orders table |
| `product_id` | INTEGER | YES | Foreign key to products table |
| `quantity` | INTEGER | YES | Number of units ordered |
| `unit_price` | DECIMAL(10,2) | YES | Price per unit at time of order |
| `created_at` | TIMESTAMP | NOT NULL | When line item was created |
| `updated_at` | TIMESTAMP | NOT NULL | When line item was last modified |
| `deleted_at` | TIMESTAMP | YES | Soft delete timestamp (rarely used) |

#### ID Ranges

| State | Row Count | ID Range | Notes |
|-------|-----------|----------|-------|
| **Baseline** | 1200 | 1-1200 | Initial order items |
| **After Day 1** | 1303 | 1-1303 | +103 new order items |
| **After Day 2** | 1387 | 1-1387 | +84 new order items |
| **After Day 3** | 1502 | 1-1502 | +115 new order items |
| **Custom Data** | varies | 5000+ | User-added test items |

#### Foreign Keys

- `order_id` → `orders.order_id`
- `product_id` → `products.product_id`

#### Typical Order Item Counts

- Most orders have 1-3 line items
- Some orders have 5+ line items
- Average: ~2.4 items per order

#### Sample Data

```
order_item_id | order_id | product_id | quantity | unit_price
--------------|----------|------------|----------|------------
1             | 1        | 2          | 1        | 29.99
2             | 1        | 12         | 2        | 79.99
1200          | 500      | 4          | 1        | 399.99
```

---

### Table: payments

Payment records for orders.

#### Schema

```sql
CREATE TABLE jaffle_shop.payments (
    payment_id     INTEGER PRIMARY KEY,
    order_id       INTEGER,
    payment_method VARCHAR(20),
    amount         DECIMAL(10,2),
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at     TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES jaffle_shop.orders(order_id)
);
```

#### Columns

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `payment_id` | INTEGER | NOT NULL | Primary key, unique payment identifier |
| `order_id` | INTEGER | YES | Foreign key to orders table |
| `payment_method` | VARCHAR(20) | YES | Payment method (credit_card, bank_transfer, etc.) |
| `amount` | DECIMAL(10,2) | YES | Payment amount |
| `created_at` | TIMESTAMP | NOT NULL | When payment was recorded |
| `updated_at` | TIMESTAMP | NOT NULL | When payment record was last modified |
| `deleted_at` | TIMESTAMP | YES | Soft delete timestamp |

#### ID Ranges

| State | Row Count | ID Range | Notes |
|-------|-----------|----------|-------|
| **Baseline** | 0 | none | No payments at baseline |
| **After Day 1** | 272 | 1-272 | First payments recorded |
| **After Day 2** | 316 | 1-316 | +44 new payments |
| **After Day 3** | 374 | 1-374 | +58 new payments |
| **Custom Data** | varies | 5000+ | User-added test payments |

#### Foreign Keys

- `order_id` → `orders.order_id`

#### Payment Methods

- **credit_card**: Credit/debit card payment
- **bank_transfer**: Direct bank transfer
- **paypal**: PayPal payment
- **gift_card**: Gift card redemption
- **coupon**: Promotional coupon

#### Sample Data

```
payment_id | order_id | payment_method | amount
-----------|----------|----------------|--------
1          | 2        | credit_card    | 159.97
2          | 3        | bank_transfer  | 89.99
272        | 560      | paypal         | 1299.99
```

---

## Database: jaffle_crm

Marketing and customer relationship management system.

### jaffle_crm Entity-Relationship Diagram

![jaffle_crm ERD](images/jaffle-crm-erd.svg)

### Tables Overview

| Table | Purpose | Baseline Rows | Pattern |
|-------|---------|---------------|---------|
| **campaigns** | Marketing campaigns | 5 | Slowly changing dimension |
| **email_activity** | Email engagement tracking | 100 | Append-only event stream |
| **web_sessions** | Website session analytics | 150 | Append-only event stream |

---

### Table: campaigns

Marketing campaign master data.

#### Schema

```sql
CREATE TABLE jaffle_crm.campaigns (
    campaign_id   INTEGER PRIMARY KEY,
    campaign_name VARCHAR(100),
    start_date    DATE,
    end_date      DATE,
    budget        DECIMAL(10,2),
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at    TIMESTAMP  -- NULL = active, non-NULL = archived
);
```

#### Columns

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `campaign_id` | INTEGER | NOT NULL | Primary key, unique campaign identifier |
| `campaign_name` | VARCHAR(100) | YES | Campaign name |
| `start_date` | DATE | YES | Campaign start date |
| `end_date` | DATE | YES | Campaign end date |
| `budget` | DECIMAL(10,2) | YES | Campaign budget |
| `created_at` | TIMESTAMP | NOT NULL | When campaign was created |
| `updated_at` | TIMESTAMP | NOT NULL | When campaign was last modified |
| `deleted_at` | TIMESTAMP | YES | Soft delete timestamp (NULL = active, non-NULL = archived) |

#### ID Ranges

| State | Row Count | ID Range | Notes |
|-------|-----------|----------|-------|
| **Baseline** | 5 | 1-5 | Initial campaigns |
| **After Day 1** | 5 | 1-5 | No new campaigns |
| **After Day 2** | 5 | 1-5 | No new campaigns |
| **After Day 3** | 5 | 1-5 | No new campaigns |
| **Custom Data** | varies | 5000+ | User-added test campaigns |

#### Sample Data

```
campaign_id | campaign_name      | start_date | end_date   | budget
------------|--------------------|-----------|-----------|---------
1           | Spring Sale 2024   | 2024-01-01 | 2024-01-31 | 5000.00
2           | Summer Clearance   | 2024-02-01 | 2024-02-28 | 7500.00
5           | Holiday Special    | 2024-05-01 | 2024-05-31 | 10000.00
```

---

### Table: email_activity

Email engagement event tracking (append-only).

#### Schema

```sql
CREATE TABLE jaffle_crm.email_activity (
    activity_id   INTEGER PRIMARY KEY,
    customer_id   INTEGER,
    campaign_id   INTEGER,
    sent_date     TIMESTAMP,
    opened        BOOLEAN,
    clicked       BOOLEAN,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- When event was recorded
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Rarely changes (append-only)
    deleted_at    TIMESTAMP,  -- Rarely used (events are immutable)
    FOREIGN KEY (campaign_id) REFERENCES jaffle_crm.campaigns(campaign_id)
);
```

#### Columns

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `activity_id` | INTEGER | NOT NULL | Primary key, unique activity event identifier |
| `customer_id` | INTEGER | YES | Customer ID (references jaffle_shop.customers) |
| `campaign_id` | INTEGER | YES | Foreign key to campaigns table |
| `sent_date` | TIMESTAMP | YES | When email was sent |
| `opened` | BOOLEAN | YES | Whether email was opened |
| `clicked` | BOOLEAN | YES | Whether email links were clicked |
| `created_at` | TIMESTAMP | NOT NULL | When event was recorded |
| `updated_at` | TIMESTAMP | NOT NULL | When event record was last modified |
| `deleted_at` | TIMESTAMP | YES | Soft delete timestamp (rarely used) |

#### ID Ranges

| State | Row Count | ID Range | Notes |
|-------|-----------|----------|-------|
| **Baseline** | 100 | 1-100 | Initial email events |
| **After Day 1** | 150 | 1-150 | +50 new email events |
| **After Day 2** | 200 | 1-200 | +50 new email events |
| **After Day 3** | 250 | 1-250 | +50 new email events |
| **Custom Data** | varies | 5000+ | User-added test events |

#### Foreign Keys

- `campaign_id` → `campaigns.campaign_id`
- `customer_id` → `jaffle_shop.customers.customer_id` (cross-database reference, not enforced by FK)

#### Engagement Metrics

- **Open Rate**: ~50% (opened = TRUE)
- **Click Rate**: ~25% (clicked = TRUE)

#### Sample Data

```
activity_id | customer_id | campaign_id | sent_date           | opened | clicked
------------|-------------|-------------|---------------------|--------|--------
1           | 1           | 1           | 2024-01-10 08:00:00 | FALSE  | FALSE
2           | 2           | 2           | 2024-01-15 10:30:00 | TRUE   | TRUE
100         | 100         | 5           | 2024-01-20 14:00:00 | TRUE   | TRUE
```

---

### Table: web_sessions

Website session tracking (append-only).

#### Schema

```sql
CREATE TABLE jaffle_crm.web_sessions (
    session_id    INTEGER PRIMARY KEY,
    customer_id   INTEGER,
    session_start TIMESTAMP,
    session_end   TIMESTAMP,
    page_views    INTEGER,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- When session was recorded
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Could update if session extends
    deleted_at    TIMESTAMP  -- Rarely used
);
```

#### Columns

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `session_id` | INTEGER | NOT NULL | Primary key, unique session identifier |
| `customer_id` | INTEGER | YES | Customer ID (references jaffle_shop.customers) |
| `session_start` | TIMESTAMP | YES | When session started |
| `session_end` | TIMESTAMP | YES | When session ended |
| `page_views` | INTEGER | YES | Number of pages viewed in session |
| `created_at` | TIMESTAMP | NOT NULL | When session was recorded |
| `updated_at` | TIMESTAMP | NOT NULL | When session record was last modified |
| `deleted_at` | TIMESTAMP | YES | Soft delete timestamp (rarely used) |

#### ID Ranges

| State | Row Count | ID Range | Notes |
|-------|-----------|----------|-------|
| **Baseline** | 150 | 1-150 | Initial web sessions |
| **After Day 1** | 200 | 1-200 | +50 new sessions |
| **After Day 2** | 250 | 1-250 | +50 new sessions |
| **After Day 3** | 300 | 1-300 | +50 new sessions |
| **Custom Data** | varies | 5000+ | User-added test sessions |

#### Session Metrics

- **Duration**: Typically 2-30 minutes
- **Page Views**: 3-20 pages per session
- **Average**: ~10 pages per session

#### Sample Data

```
session_id | customer_id | session_start        | session_end          | page_views
-----------|-------------|----------------------|----------------------|------------
1          | 82          | 2024-01-10 10:00:00  | 2024-01-10 10:02:00  | 9
2          | 36          | 2024-01-11 14:30:00  | 2024-01-11 14:45:00  | 15
150        | 61          | 2024-01-20 09:00:00  | 2024-01-20 09:11:00  | 3
```

---

## Foreign Key Relationships

### Within jaffle_shop

```
customers (customer_id)
    ↓
orders (customer_id) → orders (order_id)
    ↓                        ↓
order_items              payments
(order_id)               (order_id)
    ↓
products (product_id)
```

**Key Relationships**:
- `orders.customer_id` → `customers.customer_id`
- `order_items.order_id` → `orders.order_id`
- `order_items.product_id` → `products.product_id`
- `payments.order_id` → `orders.order_id`

### Within jaffle_crm

```
campaigns (campaign_id)
    ↓
email_activity (campaign_id)
```

**Key Relationships**:
- `email_activity.campaign_id` → `campaigns.campaign_id`

### Cross-Database References (Not Enforced)

```
jaffle_shop.customers (customer_id)
    ↓ (logical reference only)
jaffle_crm.email_activity (customer_id)
jaffle_crm.web_sessions (customer_id)
```

**Note**: Cross-database foreign keys are not enforced by database constraints, but are logically maintained by the package.

---

## Critical ID Ranges Summary

Complete ID ranges at each state for all tables:

### Baseline (Day 0)

| Table | Row Count | ID Range |
|-------|-----------|----------|
| customers | 100 | 1-100 |
| products | 20 | 1-20 |
| orders | 500 | 1-500 |
| order_items | 1200 | 1-1200 |
| payments | 0 | none |
| campaigns | 5 | 1-5 |
| email_activity | 100 | 1-100 |
| web_sessions | 150 | 1-150 |

### After Day 1

| Table | Row Count | New IDs | Cumulative Range |
|-------|-----------|---------|------------------|
| customers | 125 | 101-125 | 1-125 |
| products | 20 | none | 1-20 |
| orders | 560 | 501-560 | 1-560 |
| order_items | 1303 | 1201-1303 | 1-1303 |
| payments | 272 | 1-272 | 1-272 |
| campaigns | 5 | none | 1-5 |
| email_activity | 150 | 101-150 | 1-150 |
| web_sessions | 200 | 151-200 | 1-200 |

### After Day 2

| Table | Row Count | New IDs | Cumulative Range |
|-------|-----------|---------|------------------|
| customers | 147 | 126-147 | 1-147 |
| products | 20 | none | 1-20 |
| orders | 615 | 561-615 | 1-615 |
| order_items | 1387 | 1304-1387 | 1-1387 |
| payments | 316 | 273-316 | 1-316 |
| campaigns | 5 | none | 1-5 |
| email_activity | 200 | 151-200 | 1-200 |
| web_sessions | 250 | 201-250 | 1-250 |

### After Day 3

| Table | Row Count | New IDs | Cumulative Range |
|-------|-----------|---------|------------------|
| customers | 175 | 148-175 | 1-175 |
| products | 20 | none | 1-20 |
| orders | 680 | 616-680 | 1-680 |
| order_items | 1502 | 1388-1502 | 1-1502 |
| payments | 374 | 317-374 | 1-374 |
| campaigns | 5 | none | 1-5 |
| email_activity | 250 | 201-250 | 1-250 |
| web_sessions | 300 | 251-300 | 1-300 |

### Custom Data

If you need to insert custom data for specific test scenarios, be mindful of primary key collisions with package-managed data — this is on you to manage.

Run `origin_reset` anytime to return to a known valid baseline state.

---

## Data Patterns

### Slowly Changing Dimensions (SCD)

Tables that change slowly over time:
- **customers**: New customers added, some deleted (soft delete)
- **products**: Price updates, occasionally discontinued
- **campaigns**: Rarely change once created

### Transactional Data

Tables with high insert volume:
- **orders**: New orders daily
- **order_items**: 1-5 items per order
- **payments**: One payment per order

### Append-Only Event Streams

Tables that only insert (no updates):
- **email_activity**: Email engagement events
- **web_sessions**: Website session logs

---

## Next Steps

- See [Operations Guide](Operations-Guide) for how to load and modify source data
- See [Getting Started](Getting-Started) for installation and setup
- See [Extras](Extras) for data quality contracts

---

**Questions?** [Open an issue](https://github.com/feriksen-personal/dbt-origin-simulator-ops/issues)
