# Databricks notebook source
pg_host = "ep-old-rice-ahxgakv3.c-3.us-east-1.aws.neon.tech"
pg_db = "neondb"
pg_user = "neondb_owner"
pg_password = "npg_U3ewDmXcJ0RE"

pg_url = f"jdbc:postgresql://{pg_host}:5432/{pg_db}?sslmode=require"
pg_props = {
    "user": pg_user,
    "password": pg_password,
    "driver": "org.postgresql.Driver"
}

# Create the "bronze" database/schema if it doesn't exist
spark.sql("CREATE SCHEMA IF NOT EXISTS bronze")
spark.sql("CREATE SCHEMA IF NOT EXISTS silver")
spark.sql("CREATE SCHEMA IF NOT EXISTS gold")

tables = ["cities", "meal_types", "serve_types", "restaurant_types",
          "restaurants", "meals", "orders", "order_details"]

for t in tables:
    df = spark.read.jdbc(url=pg_url, table=t, properties=pg_props)
    df.write.format("delta").mode("overwrite").saveAsTable(f"bronze.{t}")
    print(f"✅ Loaded bronze.{t}: {df.count()} rows")
    
# ===== Connect to S3 =====

import boto3
import pandas as pd
import io

aws_access_key = "AKIATGUZCF7FVYGIIYAP"
aws_secret_key = "Secret key hidden for security reasons"
bucket = "restaurant-v2-2026"
region = "eu-north-1"

s3 = boto3.client(
    "s3",
    aws_access_key_id=aws_access_key,
    aws_secret_access_key=aws_secret_key,
    region_name=region
)

def read_csv_from_s3(prefix):
    response = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)
    obj_key = response["Contents"][0]["Key"]
    obj = s3.get_object(Bucket=bucket, Key=obj_key)
    pdf = pd.read_csv(io.BytesIO(obj["Body"].read()))
    return spark.createDataFrame(pdf)

members_df = read_csv_from_s3("raw/members/")
totals_df = read_csv_from_s3("raw/monthly_member_totals/")

members_df.write.format("delta").mode("overwrite").saveAsTable("bronze.members")
totals_df.write.format("delta").mode("overwrite").saveAsTable("bronze.monthly_member_totals")

print(f"✅ Loaded bronze.members: {members_df.count()} rows")
print(f"✅ Loaded bronze.monthly_member_totals: {totals_df.count()} rows")
