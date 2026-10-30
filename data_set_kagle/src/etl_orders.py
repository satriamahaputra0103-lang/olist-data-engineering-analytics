import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine


# ==========================================
# 1. EXTRACT: Membaca data dari CSV
# ==========================================

# Menentukan lokasi folder utama proyek
PROJECT_DIR = Path(__file__).resolve().parents[2]

# Menentukan lokasi file CSV sumber
CSV_PATH = PROJECT_DIR / "data_set_kagle" / "data" / "olist_orders_dataset.csv"

# Membaca CSV menjadi DataFrame
df = pd.read_csv(CSV_PATH)

print(f"Data berhasil dibaca: {len(df):,} baris")


# ==========================================
# 2. TRANSFORM: Mengolah data
# ==========================================

# Mengubah kolom teks menjadi tanggal dan waktu
DATE_COLUMNS = [
    "order_purchase_timestamp",
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date",
    "order_estimated_delivery_date",
]

for column in DATE_COLUMNS:
    df[column] = pd.to_datetime(df[column], errors="coerce")


# Menghitung durasi pengiriman dalam hari
df["delivery_duration_days"] = (
    df["order_delivered_customer_date"]
    - df["order_purchase_timestamp"]
).dt.total_seconds() / 86400


# Menghitung keterlambatan terhadap tanggal estimasi
df["delivery_delay_days"] = (
    df["order_delivered_customer_date"]
    - df["order_estimated_delivery_date"]
).dt.total_seconds() / 86400


# ==========================================
# 3. MEMERIKSA HASIL TRANSFORMASI
# ==========================================

print("\nStruktur data setelah transformasi:")
print(df.dtypes)

print("\nJumlah baris dan kolom:")
print(df.shape)

print("\nJumlah nilai kosong:")
print(df.isna().sum())

print("\nContoh hasil transformasi:")
print(
    df[
        [
            "order_id",
            "order_status",
            "delivery_duration_days",
            "delivery_delay_days",
        ]
    ].head()
)

# ==========================================
# 4. LOAD: Memasukkan data ke PostgreSQL
# ==========================================

# Membaca konfigurasi database dari file .env
load_dotenv(PROJECT_DIR / ".env")
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError("DATABASE_URL tidak ditemukan di file .env")

# Membuat pengelola koneksi database
engine = create_engine(DATABASE_URL)

try:
    # Memasukkan data ke tabel PostgreSQL
    df.to_sql(
        name="olist_orders",
        con=engine,
        if_exists="fail",
        index=False,
        chunksize=5000,
    )

    print("\nData berhasil dimuat ke PostgreSQL!")
    print(f"Jumlah baris yang diproses: {len(df):,}")
    print("Nama tabel: olist_orders")

finally:
    engine.dispose()