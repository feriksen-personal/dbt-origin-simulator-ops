-- jaffle_shop database schema
-- E-commerce/ERP system tables

-- Customers table
CREATE TABLE IF NOT EXISTS jaffle_shop.customers (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP  -- NULL = active, non-NULL = soft deleted
);

-- Products table
CREATE TABLE IF NOT EXISTS jaffle_shop.products (
    product_id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP  -- NULL = active, non-NULL = discontinued
);

-- Orders table
CREATE TABLE IF NOT EXISTS jaffle_shop.orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date DATE,
    status VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,  -- NULL = active, non-NULL = cancelled/deleted
    FOREIGN KEY (customer_id) REFERENCES jaffle_shop.customers(customer_id)
);

-- Order items table
CREATE TABLE IF NOT EXISTS jaffle_shop.order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,  -- Rarely used (line items typically immutable)
    FOREIGN KEY (order_id) REFERENCES jaffle_shop.orders(order_id),
    FOREIGN KEY (product_id) REFERENCES jaffle_shop.products(product_id)
);
