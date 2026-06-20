-- ============================================================
-- 05_mart_objective1.sql
-- Business Objective 1: Restaurant Revenue & Cuisine Trends
-- "Which restaurants/cuisines earn the most? Patterns by city,
--  time, meal type?"
-- These tables feed the dashboard directly.
-- ============================================================

USE DATABASE FINAL_PROJECT;
USE SCHEMA MART;

-- Revenue by restaurant
CREATE OR REPLACE TABLE MART.REVENUE_BY_RESTAURANT AS
SELECT
    restaurant_name,
    restaurant_type,
    restaurant_city,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_order)         AS total_revenue,
    AVG(total_order)         AS avg_order_value
FROM STAGING.ORDERS_ENRICHED
GROUP BY restaurant_name, restaurant_type, restaurant_city
ORDER BY total_revenue DESC;

-- Revenue by cuisine (restaurant_type)
CREATE OR REPLACE TABLE MART.REVENUE_BY_CUISINE AS
SELECT
    restaurant_type,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_order)         AS total_revenue,
    AVG(total_order)         AS avg_order_value
FROM STAGING.ORDERS_ENRICHED
GROUP BY restaurant_type
ORDER BY total_revenue DESC;

-- Revenue by city
CREATE OR REPLACE TABLE MART.REVENUE_BY_CITY AS
SELECT
    restaurant_city,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_order)         AS total_revenue
FROM STAGING.ORDERS_ENRICHED
GROUP BY restaurant_city
ORDER BY total_revenue DESC;

-- Revenue by hour of day (time patterns)
CREATE OR REPLACE TABLE MART.REVENUE_BY_HOUR AS
SELECT
    LEFT(order_hour, 2) AS hour_of_day,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_order)         AS total_revenue
FROM STAGING.ORDERS_ENRICHED
GROUP BY LEFT(order_hour, 2)
ORDER BY hour_of_day;

-- Popularity / revenue by meal type (cuisine "trend" at the dish level)
CREATE OR REPLACE TABLE MART.REVENUE_BY_MEAL_TYPE AS
SELECT
    ode.meal_type,
    ode.serve_type,
    COUNT(*)            AS times_ordered,
    SUM(ode.price)       AS total_revenue,
    AVG(ode.price)       AS avg_price
FROM STAGING.ORDER_DETAILS_ENRICHED ode
GROUP BY ode.meal_type, ode.serve_type
ORDER BY total_revenue DESC;

-- Monthly revenue trend (over time)
CREATE OR REPLACE TABLE MART.REVENUE_BY_MONTH AS
SELECT
    DATE_TRUNC('month', order_date) AS order_month,
    COUNT(DISTINCT order_id)        AS total_orders,
    SUM(total_order)                AS total_revenue
FROM STAGING.ORDERS_ENRICHED
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month;
