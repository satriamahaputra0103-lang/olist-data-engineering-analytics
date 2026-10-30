
import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, inspect


# ==================================================
# 1. KONFIGURASI PATH DAN DATABASE
# ==================================================

PROJECT_DIR = Path(__file__).resolve().parents[2]
DATA_DIR = PROJECT_DIR / "data_set_kagle" / "data"

load_dotenv(PROJECT_DIR / ".env")

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError(
        "DATABASE_URL tidak ditemukan. Periksa file .env."
    )


# ==================================================
# 2. DAFTAR CSV YANG AKAN DIMUAT
#    Tabel olist_orders TIDAK dimuat ulang.
# ==================================================

DATASETS = {
    "olist_customers": "olist_customers_dataset.csv",
    "olist_order_items": "olist_order_items_dataset.csv",
    "olist_order_payments": "olist_order_payments_dataset.csv",
    "olist_order_reviews": "olist_order_reviews_dataset.csv",
    "olist_products": "olist_products_dataset.csv",
    "olist_sellers": "olist_sellers_dataset.csv",
    "olist_geolocation": "olist_geolocation_dataset.csv",
    "product_category_name_translation":
        "product_category_name_translation.csv",
}


# ==================================================
# 3. VALIDASI FILE SUMBER
# ==================================================

for table_name, filename in DATASETS.items():
    csv_path = DATA_DIR / filename

    if not csv_path.exists():
        raise FileNotFoundError(
            f"File tidak ditemukan: {csv_path}"
        )


# ==================================================
# 4. LOAD KE POSTGRESQL
# ==================================================

engine = create_engine(DATABASE_URL)

try:
    inspector = inspect(engine)
    existing_tables = set(
        inspector.get_table_names(schema="public")
    )

    # Lindungi tabel orders yang sudah ada.
    if "olist_orders" not in existing_tables:
        raise RuntimeError(
            "Tabel public.olist_orders tidak ditemukan. "
            "Pastikan DATABASE_URL mengarah ke learning_db."
        )

    orders_count = pd.read_sql_query(
        "SELECT COUNT(*) AS total FROM public.olist_orders",
        engine,
    )["total"].iloc[0]

    print(f"Orders yang sudah ada: {orders_count:,} baris")
    print("Mulai memuat tabel tambahan...\n")

    for table_name, filename in DATASETS.items():
        csv_path = DATA_DIR / filename

        # Jangan menimpa tabel yang sudah ada.
        if table_name in existing_tables:
            print(
                f"SKIP {table_name}: tabel sudah ada. "
                "Tidak ada data yang ditimpa."
            )
            continue

        df = pd.read_csv(csv_path)

        print(
            f"Memuat {table_name}: "
            f"{len(df):,} baris..."
        )

        df.to_sql(
            name=table_name,
            con=engine,
            schema="public",
            if_exists="fail",
            index=False,
            chunksize=5000,
            method="multi",
        )

        print(f"BERHASIL: {table_name}\n")

    # Verifikasi jumlah baris tabel orders setelah proses.
    final_orders_count = pd.read_sql_query(
        "SELECT COUNT(*) AS total FROM public.olist_orders",
        engine,
    )["total"].iloc[0]

    if final_orders_count != orders_count:
        raise RuntimeError(
            "Jumlah orders berubah! Periksa database."
        )

    print("====================================")
    print("LOAD SELESAI")
    print(f"Orders sebelum : {orders_count:,}")
    print(f"Orders sesudah : {final_orders_count:,}")
    print("Tabel orders tidak diubah.")
    print("====================================")

finally:
    engine.dispose()
