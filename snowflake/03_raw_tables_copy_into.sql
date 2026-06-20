-- ============================================================
-- 03_raw_tables_copy_into.sql
-- Creates RAW tables and loads them from the S3 stages.
-- Run 02_stage_setup.sql first.
-- ============================================================

USE DATABASE FINAL_PROJECT;
USE SCHEMA RAW;

-- ---------- Object-store source (from S3_RAW_STAGE) ----------

CREATE OR REPLACE TABLE RAW.MEMBERS (
    id INTEGER,
    first_name STRING,
    surname STRING,
    sex STRING,
    email STRING,
    city_id INTEGER,
    monthly_budget FLOAT
);

CREATE OR REPLACE TABLE RAW.MONTHLY_MEMBER_TOTALS (
    member_id INTEGER,
    first_name STRING,
    surname STRING,
    sex STRING,
    email STRING,
    city STRING,
    year INTEGER,
    month INTEGER,
    order_count INTEGER,
    meals_count INTEGER,
    monthly_budget FLOAT,
    total_expense FLOAT,
    balance FLOAT,
    commission FLOAT
);

COPY INTO RAW.MEMBERS
    FROM @RAW.S3_RAW_STAGE/members/
    FILE_FORMAT = (FORMAT_NAME = RAW.CSV_FORMAT)
    ON_ERROR = 'CONTINUE';

COPY INTO RAW.MONTHLY_MEMBER_TOTALS
    FROM @RAW.S3_RAW_STAGE/monthly_member_totals/
    FILE_FORMAT = (FORMAT_NAME = RAW.CSV_FORMAT)
    ON_ERROR = 'CONTINUE';

-- ---------- DB source, bridged via S3 (from S3_POSTGRES_EXPORT_STAGE) ----------

CREATE OR REPLACE TABLE RAW.CITIES (id INTEGER, city STRING);

CREATE OR REPLACE TABLE RAW.MEAL_TYPES (id INTEGER, meal_type STRING);

CREATE OR REPLACE TABLE RAW.SERVE_TYPES (id INTEGER, serve_type STRING);

CREATE OR REPLACE TABLE RAW.RESTAURANT_TYPES (id INTEGER, restaurant_type STRING);

CREATE OR REPLACE TABLE RAW.RESTAURANTS (
    id INTEGER,
    restaurant_name STRING,
    restaurant_type_id INTEGER,
    income_persentage FLOAT,
    city_id INTEGER
);

CREATE OR REPLACE TABLE RAW.MEALS (
    id INTEGER,
    restaurant_id INTEGER,
    serve_type_id INTEGER,
    meal_type_id INTEGER,
    hot_cold STRING,
    meal_name STRING,
    price FLOAT
);

CREATE OR REPLACE TABLE RAW.ORDERS (
    id INTEGER,
    order_date DATE,
    order_hour STRING,
    member_id INTEGER,
    restaurant_id INTEGER,
    total_order FLOAT
);

CREATE OR REPLACE TABLE RAW.ORDER_DETAILS (
    id INTEGER,
    order_id INTEGER,
    meal_id INTEGER
);

COPY INTO RAW.CITIES FROM @RAW.S3_POSTGRES_EXPORT_STAGE/cities/
    FILE_FORMAT = (FORMAT_NAME = RAW.CSV_FORMAT) ON_ERROR = 'CONTINUE';

COPY INTO RAW.MEAL_TYPES FROM @RAW.S3_POSTGRES_EXPORT_STAGE/meal_types/
    FILE_FORMAT = (FORMAT_NAME = RAW.CSV_FORMAT) ON_ERROR = 'CONTINUE';

COPY INTO RAW.SERVE_TYPES FROM @RAW.S3_POSTGRES_EXPORT_STAGE/serve_types/
    FILE_FORMAT = (FORMAT_NAME = RAW.CSV_FORMAT) ON_ERROR = 'CONTINUE';

COPY INTO RAW.RESTAURANT_TYPES FROM @RAW.S3_POSTGRES_EXPORT_STAGE/restaurant_types/
    FILE_FORMAT = (FORMAT_NAME = RAW.CSV_FORMAT) ON_ERROR = 'CONTINUE';

COPY INTO RAW.RESTAURANTS FROM @RAW.S3_POSTGRES_EXPORT_STAGE/restaurants/
    FILE_FORMAT = (FORMAT_NAME = RAW.CSV_FORMAT) ON_ERROR = 'CONTINUE';

COPY INTO RAW.MEALS FROM @RAW.S3_POSTGRES_EXPORT_STAGE/meals/
    FILE_FORMAT = (FORMAT_NAME = RAW.CSV_FORMAT) ON_ERROR = 'CONTINUE';

COPY INTO RAW.ORDERS FROM @RAW.S3_POSTGRES_EXPORT_STAGE/orders/
    FILE_FORMAT = (FORMAT_NAME = RAW.CSV_FORMAT) ON_ERROR = 'CONTINUE';

COPY INTO RAW.ORDER_DETAILS FROM @RAW.S3_POSTGRES_EXPORT_STAGE/order_details/
    FILE_FORMAT = (FORMAT_NAME = RAW.CSV_FORMAT) ON_ERROR = 'CONTINUE';

-- Quick sanity checks
SELECT 'members' AS tbl, COUNT(*) FROM RAW.MEMBERS
UNION ALL SELECT 'monthly_member_totals', COUNT(*) FROM RAW.MONTHLY_MEMBER_TOTALS
UNION ALL SELECT 'orders', COUNT(*) FROM RAW.ORDERS
UNION ALL SELECT 'order_details', COUNT(*) FROM RAW.ORDER_DETAILS
UNION ALL SELECT 'meals', COUNT(*) FROM RAW.MEALS
UNION ALL SELECT 'restaurants', COUNT(*) FROM RAW.RESTAURANTS;
