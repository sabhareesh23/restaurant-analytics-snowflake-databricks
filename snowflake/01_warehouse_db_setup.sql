-- ============================================================
-- 01_warehouse_db_setup.sql
-- Run this first, in a Snowflake worksheet, as ACCOUNTADMIN
-- (or a role with CREATE WAREHOUSE / CREATE DATABASE rights).
-- ============================================================

-- A small, auto-suspending warehouse keeps this FREE/cheap.
-- "X-SMALL" + auto_suspend=60s means it shuts off 60s after you stop using it.
CREATE WAREHOUSE IF NOT EXISTS FINAL_PROJECT_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for SRH final project (Restaurant + Member analytics)';

CREATE DATABASE IF NOT EXISTS FINAL_PROJECT
    COMMENT = 'DB combining Postgres (orders/restaurants) + S3 (members) sources';

USE DATABASE FINAL_PROJECT;

-- 3 schemas = the 3 layers of our pipeline (like Bronze/Silver/Gold, Snowflake-style)
CREATE SCHEMA IF NOT EXISTS RAW;        -- raw, untouched data straight from S3
CREATE SCHEMA IF NOT EXISTS STAGING;    -- cleaned, joined, typed
CREATE SCHEMA IF NOT EXISTS MART;       -- final business-ready tables for the dashboard

USE WAREHOUSE FINAL_PROJECT_WH;
