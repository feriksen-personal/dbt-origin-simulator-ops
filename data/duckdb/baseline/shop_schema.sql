-- jaffle_shop database schema
-- E-commerce/ERP system tables

-- Create jaffle_shop schema
CREATE SCHEMA IF NOT EXISTS jaffle_shop;

-- Note: DuckDB does not support COMMENT ON SCHEMA (only tables and columns)
-- Schema description: Enterprise Resource Planning (ERP) schema containing transactional e-commerce data.
-- This schema includes customer master data, product catalog, orders, order line items, and payment transactions.
-- Tables use soft delete pattern with deleted_at timestamp.

-- Customers table
CREATE TABLE IF NOT EXISTS jaffle_shop.customers (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

COMMENT ON TABLE jaffle_shop.customers IS 'Customer master data table';
COMMENT ON COLUMN jaffle_shop.customers.customer_id IS 'Unique customer identifier';
COMMENT ON COLUMN jaffle_shop.customers.first_name IS 'Customer first name';
COMMENT ON COLUMN jaffle_shop.customers.last_name IS 'Customer last name';
COMMENT ON COLUMN jaffle_shop.customers.email IS 'Customer email address';
COMMENT ON COLUMN jaffle_shop.customers.created_at IS 'Record creation timestamp';
COMMENT ON COLUMN jaffle_shop.customers.updated_at IS 'Record last update timestamp';
COMMENT ON COLUMN jaffle_shop.customers.deleted_at IS 'Soft delete timestamp (NULL = active, non-NULL = deleted)';

-- Products table
CREATE TABLE IF NOT EXISTS jaffle_shop.products (
    product_id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

COMMENT ON TABLE jaffle_shop.products IS 'Product catalog table';
COMMENT ON COLUMN jaffle_shop.products.product_id IS 'Unique product identifier';
COMMENT ON COLUMN jaffle_shop.products.name IS 'Product name';
COMMENT ON COLUMN jaffle_shop.products.category IS 'Product category';
COMMENT ON COLUMN jaffle_shop.products.price IS 'Product unit price';
COMMENT ON COLUMN jaffle_shop.products.created_at IS 'Record creation timestamp';
COMMENT ON COLUMN jaffle_shop.products.updated_at IS 'Record last update timestamp';
COMMENT ON COLUMN jaffle_shop.products.deleted_at IS 'Soft delete timestamp (NULL = active, non-NULL = discontinued)';

-- Orders table
CREATE TABLE IF NOT EXISTS jaffle_shop.orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date DATE,
    status VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES jaffle_shop.customers(customer_id)
);

COMMENT ON TABLE jaffle_shop.orders IS 'Customer orders table';
COMMENT ON COLUMN jaffle_shop.orders.order_id IS 'Unique order identifier';
COMMENT ON COLUMN jaffle_shop.orders.customer_id IS 'Foreign key to customers table';
COMMENT ON COLUMN jaffle_shop.orders.order_date IS 'Order placement date';
COMMENT ON COLUMN jaffle_shop.orders.status IS 'Order status (pending, shipped, delivered, etc.)';
COMMENT ON COLUMN jaffle_shop.orders.created_at IS 'Record creation timestamp';
COMMENT ON COLUMN jaffle_shop.orders.updated_at IS 'Record last update timestamp';
COMMENT ON COLUMN jaffle_shop.orders.deleted_at IS 'Soft delete timestamp (NULL = active, non-NULL = cancelled)';

-- Order items table
CREATE TABLE IF NOT EXISTS jaffle_shop.order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES jaffle_shop.orders(order_id),
    FOREIGN KEY (product_id) REFERENCES jaffle_shop.products(product_id)
);

COMMENT ON TABLE jaffle_shop.order_items IS 'Order line items table';
COMMENT ON COLUMN jaffle_shop.order_items.order_item_id IS 'Unique order line item identifier';
COMMENT ON COLUMN jaffle_shop.order_items.order_id IS 'Foreign key to orders table';
COMMENT ON COLUMN jaffle_shop.order_items.product_id IS 'Foreign key to products table';
COMMENT ON COLUMN jaffle_shop.order_items.quantity IS 'Quantity ordered';
COMMENT ON COLUMN jaffle_shop.order_items.unit_price IS 'Price per unit at time of order';
COMMENT ON COLUMN jaffle_shop.order_items.created_at IS 'Record creation timestamp';
COMMENT ON COLUMN jaffle_shop.order_items.updated_at IS 'Record last update timestamp';
COMMENT ON COLUMN jaffle_shop.order_items.deleted_at IS 'Soft delete timestamp (rarely used)';

-- Payments table
CREATE TABLE IF NOT EXISTS jaffle_shop.payments (
    payment_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    payment_method VARCHAR(20),
    amount DECIMAL(10,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES jaffle_shop.orders(order_id)
);

COMMENT ON TABLE jaffle_shop.payments IS 'Payment transactions table';
COMMENT ON COLUMN jaffle_shop.payments.payment_id IS 'Unique payment identifier';
COMMENT ON COLUMN jaffle_shop.payments.order_id IS 'Foreign key to orders table';
COMMENT ON COLUMN jaffle_shop.payments.payment_method IS 'Payment method (credit_card, bank_transfer, etc.)';
COMMENT ON COLUMN jaffle_shop.payments.amount IS 'Payment amount';
COMMENT ON COLUMN jaffle_shop.payments.created_at IS 'Record creation timestamp';
COMMENT ON COLUMN jaffle_shop.payments.updated_at IS 'Record last update timestamp';
COMMENT ON COLUMN jaffle_shop.payments.deleted_at IS 'Soft delete timestamp';
