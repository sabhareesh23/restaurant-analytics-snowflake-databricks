-- ============================================================
-- 04_staging_transform.sql
-- STAGING = cleaned + joined version of RAW.
-- Using TABLES (not views) here so re-running is fast and the
-- automation Task in 07 can just call these as a refresh step.
-- ============================================================

USE DATABASE FINAL_PROJECT;
USE SCHEMA STAGING;

-- Orders joined with their restaurant + city + restaurant type
CREATE OR REPLACE TABLE STAGING.ORDERS_ENRICHED AS
SELECT
    o.id                AS order_id,
    o.order_date,
    o.order_hour,
    o.member_id,
    o.total_order,
    r.id                AS restaurant_id,
    r.restaurant_name,
    rt.restaurant_type,
    c.city              AS restaurant_city
FROM RAW.ORDERS o
LEFT JOIN RAW.RESTAURANTS r        ON o.restaurant_id = r.id
LEFT JOIN RAW.RESTAURANT_TYPES rt  ON r.restaurant_type_id = rt.id
LEFT JOIN RAW.CITIES c             ON r.city_id = c.id;

-- Order details (each meal in an order) joined with meal info
CREATE OR REPLACE TABLE STAGING.ORDER_DETAILS_ENRICHED AS
SELECT
    od.id           AS order_detail_id,
    od.order_id,
    m.id            AS meal_id,
    m.meal_name,
    m.price,
    m.hot_cold,
    mt.meal_type,
    st.serve_type
FROM RAW.ORDER_DETAILS od
LEFT JOIN RAW.MEALS m        ON od.meal_id = m.id
LEFT JOIN RAW.MEAL_TYPES mt  ON m.meal_type_id = mt.id
LEFT JOIN RAW.SERVE_TYPES st ON m.serve_type_id = st.id;

-- Members joined with their city name
CREATE OR REPLACE TABLE STAGING.MEMBERS_ENRICHED AS
SELECT
    mem.id    AS member_id,
    mem.first_name,
    mem.surname,
    mem.sex,
    mem.email,
    mem.monthly_budget,
    c.city    AS member_city
FROM RAW.MEMBERS mem
LEFT JOIN RAW.CITIES c ON mem.city_id = c.id;

SELECT COUNT(*) FROM STAGING.ORDERS_ENRICHED;
SELECT COUNT(*) FROM STAGING.ORDER_DETAILS_ENRICHED;
SELECT COUNT(*) FROM STAGING.MEMBERS_ENRICHED;
