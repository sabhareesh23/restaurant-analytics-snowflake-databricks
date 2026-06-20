-- ============================================================
-- DB-side tables for the "Restaurant Revenue & Cuisine Trends"
-- business objective. These live in PostgreSQL.
-- Lookup tables first, then tables that reference them (FKs).
-- ============================================================

DROP TABLE IF EXISTS order_details CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS meals CASCADE;
DROP TABLE IF EXISTS restaurants CASCADE;
DROP TABLE IF EXISTS restaurant_types CASCADE;
DROP TABLE IF EXISTS meal_types CASCADE;
DROP TABLE IF EXISTS serve_types CASCADE;
DROP TABLE IF EXISTS cities CASCADE;

CREATE TABLE cities (
    id   INTEGER PRIMARY KEY,
    city TEXT NOT NULL
);

CREATE TABLE meal_types (
    id        INTEGER PRIMARY KEY,
    meal_type TEXT NOT NULL
);

CREATE TABLE serve_types (
    id         INTEGER PRIMARY KEY,
    serve_type TEXT NOT NULL
);

CREATE TABLE restaurant_types (
    id              INTEGER PRIMARY KEY,
    restaurant_type TEXT NOT NULL
);

CREATE TABLE restaurants (
    id                  INTEGER PRIMARY KEY,
    restaurant_name     TEXT NOT NULL,
    restaurant_type_id  INTEGER REFERENCES restaurant_types(id),
    income_persentage   NUMERIC,
    city_id             INTEGER REFERENCES cities(id)
);

CREATE TABLE meals (
    id             INTEGER PRIMARY KEY,
    restaurant_id  INTEGER REFERENCES restaurants(id),
    serve_type_id  INTEGER REFERENCES serve_types(id),
    meal_type_id   INTEGER REFERENCES meal_types(id),
    hot_cold       TEXT,
    meal_name      TEXT,
    price          NUMERIC
);

-- NOTE: member_id is NOT a foreign key here on purpose.
-- "members" lives in the Object Store (S3), not in this database.
-- We'll join orders <-> members later in Spark/Snowflake, not via a DB FK.
CREATE TABLE orders (
    id             INTEGER PRIMARY KEY,
    order_date     DATE,
    order_hour     TIME,
    member_id      INTEGER,
    restaurant_id  INTEGER REFERENCES restaurants(id),
    total_order    NUMERIC
);

CREATE TABLE order_details (
    id        INTEGER PRIMARY KEY,
    order_id  INTEGER REFERENCES orders(id),
    meal_id   INTEGER REFERENCES meals(id)
);

-- Helpful indexes for the dashboard queries
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_restaurant ON orders(restaurant_id);
CREATE INDEX idx_order_details_order ON order_details(order_id);
CREATE INDEX idx_order_details_meal ON order_details(meal_id);
