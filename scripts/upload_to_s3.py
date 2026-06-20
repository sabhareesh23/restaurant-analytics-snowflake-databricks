"""
upload_to_s3.py
----------------
🎯 What this does:
Uploads the 2 "Object Store-side" CSV files (members.csv,
monthly_member_totals.csv) into your AWS S3 bucket.

🪜 Why S3 and not Postgres for these?
The project requires combining a DB source AND an Object Store source.
Members + their monthly spending totals are simple, flat files —
a perfect fit for "just drop the file in a bucket" storage.

🪜 How to run:
1. pip install -r requirements.txt
2. Copy .env.example to .env and fill in your AWS keys + bucket name
3. python scripts/upload_to_s3.py
"""

import os
from pathlib import Path

import boto3
from dotenv import load_dotenv

load_dotenv()

AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION", "eu-central-1")
S3_BUCKET = os.getenv("S3_BUCKET")

BASE_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = BASE_DIR / "data" / "raw"

# These are the "Object Store" source files per the project's locked-in objectives
FILES_TO_UPLOAD = [
    ("members.csv", "raw/members/members.csv"),
    ("monthly_member_totals.csv", "raw/monthly_member_totals/monthly_member_totals.csv"),
]


def main():
    print(f"🔌 Connecting to S3 bucket: {S3_BUCKET} ...")
    s3 = boto3.client(
        "s3",
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION,
    )

    for local_name, s3_key in FILES_TO_UPLOAD:
        local_path = RAW_DIR / local_name
        print(f"📦 Uploading {local_name} -> s3://{S3_BUCKET}/{s3_key} ...")
        s3.upload_file(str(local_path), S3_BUCKET, s3_key)
        print("   ✅ Done")

    print("\n🎉 All Object Store-side files uploaded successfully!")
    print(f"   Check: https://s3.console.aws.amazon.com/s3/buckets/{S3_BUCKET}")


if __name__ == "__main__":
    main()
