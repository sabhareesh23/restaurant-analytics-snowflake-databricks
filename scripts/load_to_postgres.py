"""
load_to_postgres.py
--------------------
🎯 What this does:
1. Connects to your PostgreSQL database (Neon, RDS, or any Postgres)
2. Creates the tables (sql/create_tables.sql)
3. Loads the 8 "DB-side" CSV files into those tables

Think of this like a waiter (this script) carrying trays (CSV rows)
from the kitchen counter (data/raw/*.csv) into the dining tables
(Postgres tables) in the correct order so nothing falls over (FK errors).

🪜 How to run:
1. pip install -r requirements.txt
2. Copy .env.example to .env and fill in your real Postgres connection info
3. python scripts/load_to_postgres.py
"""

import os
import csv
import io
from pathlib import Path

import psycopg2
from dotenv import load_dotenv

# ---- 1. Load secrets from .env (never hard-code passwords!) ----
load_dotenv()

DB_HOST = os.getenv("PG_HOST")
DB_PORT = os.getenv("PG_PORT", "5432")
DB_NAME = os.getenv("PG_DATABASE")
DB_USER = os.getenv("PG_USER")
DB_PASSWORD = os.getenv("PG_PASSWORD")
DB_SSLMODE = os.getenv("PG_SSLMODE", "require")  # Neon needs "require"

BASE_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = BASE_DIR / "data" / "raw"
SQL_FILE = BASE_DIR / "sql" / "create_tables.sql"

# ---- 2. Order matters! Parents before children (foreign keys) ----
# (csv_filename, table_name, [column_rename_map])
LOAD_ORDER = [
    ("cities.csv", "cities", None),
    ("meal_types.csv", "meal_types", None),
    ("serve_types.csv", "serve_types", None),
    ("restaurant_types.csv", "restaurant_types", None),
    ("restaurants.csv", "restaurants", None),
    ("meals.csv", "meals", None),
    # orders.csv columns: id,date,hour,member_id,restaurant_id,total_order
    # we rename "date" -> "order_date" and "hour" -> "order_hour" to match our schema
    ("orders.csv", "orders", {"date": "order_date", "hour": "order_hour"}),
    ("order_details.csv", "order_details", None),
]


def get_connection():
    print(f"🔌 Connecting to Postgres at {DB_HOST}:{DB_PORT}/{DB_NAME} ...")
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        sslmode=DB_SSLMODE,
    )
    print("✅ Connected!")
    return conn


def create_tables(conn):
    print("🛠️  Creating tables from sql/create_tables.sql ...")
    with open(SQL_FILE, "r") as f:
        ddl = f.read()
    with conn.cursor() as cur:
        cur.execute(ddl)
    conn.commit()
    print("✅ Tables created.")


def load_csv(conn, csv_filename, table_name, rename_map):
    csv_path = RAW_DIR / csv_filename
    print(f"📦 Loading {csv_filename} -> {table_name} ...")

    with open(csv_path, "r", newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader)
        if rename_map:
            header = [rename_map.get(col, col) for col in header]

        # Re-pack rows into an in-memory CSV buffer with the (possibly renamed) header
        buffer = io.StringIO()
        writer = csv.writer(buffer)
        for row in reader:
            writer.writerow(row)
        buffer.seek(0)

    columns_sql = ", ".join(header)
    with conn.cursor() as cur:
        cur.copy_expert(
            f"COPY {table_name} ({columns_sql}) FROM STDIN WITH (FORMAT csv)",
            buffer,
        )
    conn.commit()

    with conn.cursor() as cur:
        cur.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cur.fetchone()[0]
    print(f"   ✅ {table_name}: {count} rows loaded")


def main():
    conn = get_connection()
    try:
        create_tables(conn)
        for csv_filename, table_name, rename_map in LOAD_ORDER:
            load_csv(conn, csv_filename, table_name, rename_map)
        print("\n🎉 All DB-side tables loaded successfully!")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
