-- ============================================================
-- 02_stage_setup.sql
-- Connects Snowflake to your S3 bucket.
--
-- ⚠️ Replace the placeholders:
--   <YOUR_BUCKET>          e.g. srh-finalproject-yourname
--   <YOUR_AWS_KEY_ID>      from your IAM user
--   <YOUR_AWS_SECRET_KEY>  from your IAM user
--
-- 🔒 Note: for a real production project you'd use a STORAGE INTEGRATION
-- (IAM role + trust policy) instead of raw keys. For a course project,
-- direct credentials are simpler and totally fine.
-- ============================================================

USE DATABASE FINAL_PROJECT;
USE SCHEMA RAW;

-- A "file format" tells Snowflake how to read the CSVs (comma-separated, 1 header row)
CREATE OR REPLACE FILE FORMAT RAW.CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('', 'NULL')
    EMPTY_FIELD_AS_NULL = TRUE;

-- Stage #1: the Object Store source (members, monthly_member_totals)
-- This points at s3://<bucket>/raw/
CREATE OR REPLACE STAGE RAW.S3_RAW_STAGE
    URL = 's3://<YOUR_BUCKET>/raw/'
    CREDENTIALS = (AWS_KEY_ID = '<YOUR_AWS_KEY_ID>' AWS_SECRET_KEY = '<YOUR_AWS_SECRET_KEY>')
    FILE_FORMAT = RAW.CSV_FORMAT
    COMMENT = 'Object-store source: members + monthly_member_totals';

-- Stage #2: the "bridged" DB source (Postgres tables exported to S3)
-- This points at s3://<bucket>/postgres_export/
CREATE OR REPLACE STAGE RAW.S3_POSTGRES_EXPORT_STAGE
    URL = 's3://<YOUR_BUCKET>/postgres_export/'
    CREDENTIALS = (AWS_KEY_ID = '<YOUR_AWS_KEY_ID>' AWS_SECRET_KEY = '<YOUR_AWS_SECRET_KEY>')
    FILE_FORMAT = RAW.CSV_FORMAT
    COMMENT = 'DB source bridged via S3: orders, restaurants, meals, etc.';

-- Quick sanity check: list files currently sitting in each stage
LIST @RAW.S3_RAW_STAGE;
LIST @RAW.S3_POSTGRES_EXPORT_STAGE;
