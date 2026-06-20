# Final Project — Restaurant Orders & Member Spending Analytics

**Course:** SRH University Campus Hamburg — Summer 2026
**Team:** [Your Name] (Databricks / Medallion) + [Partner Name] (Snowflake)

## 🎯 Business Objectives

| # | Objective | Question it answers | Source |
|---|-----------|----------------------|--------|
| 1 | Restaurant Revenue & Cuisine Trends | Which restaurants/cuisines earn the most? Patterns by city, time, meal type? | 🗄️ PostgreSQL (DB) |
| 2 | Customer Spending & Budget Behavior | Which members overspend their monthly budget? Who are the top spenders? Risk patterns? | ☁️ AWS S3 (Object Store) |

## 📦 Data Source

Dataset: restaurant ordering platform sample data ("now" dataset) — provided as part of the course assignment.
Files: `cities`, `meal_types`, `serve_types`, `restaurant_types`, `restaurants`, `meals`, `orders`,
`order_details` (→ Database), and `members`, `monthly_member_totals` (→ Object Store).

> ⚠️ No synthetic/generated data is used except where explicitly allowed (new incoming records used
> for the "pipeline auto-update" test, generated in the same shape as the original dataset).

## 🏗️ Architecture

```
            ┌─────────────────────┐        ┌─────────────────────┐
            │   PostgreSQL (DB)   │        │     AWS S3          │
            │  orders, meals,     │        │  members,           │
            │  restaurants, etc.  │        │  monthly_member_     │
            │                     │        │  totals              │
            └─────────┬───────────┘        └──────────┬──────────┘
                      │                                │
            ┌─────────┴────────────────────────────────┴──────────┐
            │                                                       │
   ┌────────▼─────────┐                                  ┌──────────▼─────────┐
   │     DATABRICKS    │                                  │      SNOWFLAKE      │
   │ Bronze→Silver→Gold│                                  │  RAW→STAGING→MART   │
   │   (Spark / PySpark)│                                  │  (SQL / Snowpark)   │
   └────────┬───────────┘                                  └──────────┬──────────┘
            │                                                          │
            └───────────────────────┬──────────────────────────────────┘
                                     ▼
                          📊 DASHBOARD (2 business objectives)
```

Two parallel pipelines are built on the **same two business objectives**, using the **same two
sources**, so we can compare a Databricks Medallion approach vs. a Snowflake approach.

## 📁 Repo Structure

```
.
├── data/raw/            # original CSVs (small sample, kept for reproducibility)
├── sql/create_tables.sql# Postgres DDL for the DB-side tables
├── scripts/
│   ├── load_to_postgres.py   # loads DB-side CSVs into Postgres
│   └── upload_to_s3.py       # uploads Object-store CSVs into S3
├── databricks/          # Medallion architecture notebooks (Partner A)
├── snowflake/           # Snowflake pipeline + SQL (Partner B)
├── dashboard/           # final dashboard app/config
├── docs/ai_prompts.md   # log of AI-assistant prompts used (per assignment rule)
└── .env.example         # template for secrets (copy to .env, never commit .env)
```

## 🪜 How to Run (Step 1 — load the raw sources)

```bash
# 1. Create a virtual environment
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Set up your secrets
cp .env.example .env
# now edit .env with your real Postgres + AWS credentials

# 4. Load the DB-side tables into Postgres
python scripts/load_to_postgres.py

# 5. Upload the Object-store-side files into S3
python scripts/upload_to_s3.py
```

## 🔄 Testing the "auto-update" requirement

A new batch of orders/members data is added to Postgres/S3 → pipelines (Databricks Bronze ingestion
job / Snowflake Snowpipe or scheduled task) automatically pick it up → Gold/Mart tables refresh →
dashboard reflects new numbers without manual rework. See `databricks/README.md` and
`snowflake/README.md` for how each platform implements this.

## 👥 Team Split

- **Partner A — Databricks (Medallion):** bronze/silver/gold notebooks in `/databricks`
- **Partner B — Snowflake:** SQL/Snowpark pipeline in `/snowflake`
- Both consume the same Postgres + S3 sources, and both feed the same two business objectives
  into the dashboard.
