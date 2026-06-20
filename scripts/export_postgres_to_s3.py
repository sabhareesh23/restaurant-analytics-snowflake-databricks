"""
export_postgres_to_s3.py
-------------------------
🎯 What this does:
Snowflake can't query Postgres directly, but it CAN read files from S3.
So this script "bridges" the DB source into Snowflake by exporting each
Postgres table to a CSV file in S3, under s3://<bucket>/postgres_export/<table>/.

Run this:
  - once, right after load_to_postgres.py, to get the initial data into S3
  - again, any time new rows are added to Postgres (or on a schedule / cron),
    so Snowflake's Snowpipe picks up the new file automatically.

🪜 How to run:
    python scripts/export_postgres_to_s3.py
"""

import os
from pathlib import Path
from datetime import datetime, timezone

import psycopg2
import boto3
from dotenv import load_dotenv

load_dotenv()

PG_HOST = os.getenv("PG_HOST")
PG_PORT = os.getenv("PG_PORT", "5432")
PG_DATABASE = os.getenv("PG_DATABASE")
PG_USER = os.getenv("PG_USER")
PG_PASSWORD = os.getenv("PG_PASSWORD")
PG_SSLMODE = os.getenv("PG_SSLMODE", "require")

AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION", "eu-central-1")
S3_BUCKET = os.getenv("S3_BUCKET")

TABLES = [
    "cities",
    "meal_types",
    "serve_types",
    "restaurant_types",
    "restaurants",
    "meals",
    "orders",
    "order_details",
]

TMP_DIR = Path("/tmp/pg_export")
TMP_DIR.mkdir(parents=True, exist_ok=True)


def export_table(conn, s3, table_name):
    local_file = TMP_DIR / f"{table_name}.csv"
    print(f"📤 Exporting {table_name} from Postgres ...")

    with open(local_file, "w", newline="", encoding="utf-8") as f:
        with conn.cursor() as cur:
            cur.copy_expert(
                f"COPY (SELECT * FROM {table_name}) TO STDOUT WITH (FORMAT csv, HEADER true)",
                f,
            )

    # Use a timestamp in the filename so every export is a NEW file in S3.
    # This is what triggers Snowpipe auto-ingest (it reacts to new files, not overwrites).
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S")
    s3_key = f"postgres_export/{table_name}/{table_name}_{ts}.csv"

    print(f"📦 Uploading -> s3://{S3_BUCKET}/{s3_key}")
    s3.upload_file(str(local_file), S3_BUCKET, s3_key)
    print(f"   ✅ Done")


def main():
    conn = psycopg2.connect(
        host=PG_HOST, port=PG_PORT, dbname=PG_DATABASE,
        user=PG_USER, password=PG_PASSWORD, sslmode=PG_SSLMODE,
    )
    s3 = boto3.client(
        "s3",
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION,
    )
    try:
        for table in TABLES:
            export_table(conn, s3, table)
        print("\n🎉 All Postgres tables exported to S3!")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
