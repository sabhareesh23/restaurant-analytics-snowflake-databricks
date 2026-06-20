# Databricks — Medallion Architecture (Partner A)

This folder will hold the Databricks notebooks for this project.

## Planned structure (Bronze → Silver → Gold)

```
databricks/
├── 01_bronze_ingest.py      # raw load from Postgres (JDBC) + S3 into Delta bronze tables
├── 02_silver_clean.py       # clean, dedupe, join lookups, fix types
├── 03_gold_objective1.py    # Restaurant Revenue & Cuisine Trends aggregates
├── 04_gold_objective2.py    # Customer Spending & Budget Behavior aggregates
└── 05_autoloader_job.json   # Databricks Job config for auto-refresh on new data
```

## 🥉🥈🥇 Medallion layers — quick explainer

- **Bronze**: raw copy of source data, as-is (from Postgres via JDBC, and from S3 raw files)
- **Silver**: cleaned + joined (e.g. orders joined with restaurants, meals, cities)
- **Gold**: business-ready aggregates that directly answer the 2 objectives, feeding the dashboard

> This README will be filled in with real notebook links/exports once Partner A builds the
> pipeline in Databricks.
