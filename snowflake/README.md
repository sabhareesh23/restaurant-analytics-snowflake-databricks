# Snowflake Pipeline (Partner B)

This folder will hold the Snowflake SQL/Snowpark scripts for this project.

## Planned structure (RAW → STAGING → MART)

```
snowflake/
├── 01_raw_setup.sql          # external stage to S3 + stage/tables for Postgres exports
├── 02_staging_transform.sql  # cleaned/joined views or tables
├── 03_mart_objective1.sql    # Restaurant Revenue & Cuisine Trends
├── 04_mart_objective2.sql    # Customer Spending & Budget Behavior
└── 05_snowpipe_task.sql      # Snowpipe / Task + Stream for auto-refresh on new data
```

## ❄️ Quick explainer

- **RAW**: data loaded as-is from S3 (external stage) and from Postgres (exported or via
  a connector) into raw Snowflake tables
- **STAGING**: cleaned/joined version of RAW
- **MART**: final business-ready tables that answer the 2 objectives, feeding the dashboard
- **Snowpipe + Streams/Tasks**: automatically detect new files in S3 / new rows and refresh
  the MART tables without manual re-running

> This README will be filled in with real SQL once Partner B builds the pipeline in Snowflake.
