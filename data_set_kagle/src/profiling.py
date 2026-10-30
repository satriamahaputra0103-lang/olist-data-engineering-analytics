from pathlib import Path
import pandas as pd

# Menentukan lokasi file CSV
project_dir = Path(__file__).resolve().parents[2]
csv_path = project_dir / "data_set_kagle" / "data" / "olist_orders_dataset.csv"

# Membaca file CSV
df = pd.read_csv(csv_path)

# Mengubah kolom teks menjadi tanggal dan waktu
date_columns = [
    "order_purchase_timestamp",
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date",
    "order_estimated_delivery_date",
]

for column in date_columns:
    df[column] = pd.to_datetime(df[column], errors="coerce")

print("\nTipe data setelah transformasi:")
print(df.dtypes)

# Menghitung durasi pengiriman dalam hari
df["delivery_duration_days"] = (
    df["order_delivered_customer_date"]
    - df["order_purchase_timestamp"]
).dt.total_seconds() / 86400

print("\nContoh durasi pengiriman:")
print(
    df[
        [
            "order_purchase_timestamp",
            "order_delivered_customer_date",
            "delivery_duration_days",
        ]
    ].head(10)
)

# Menampilkan lima baris pertama
print(df.head())

print("Jumlah baris dan kolom:", df.shape)
print("Penggunaan memori:", df.memory_usage(deep=True).sum() / 1024**2, "MB")

# Memeriksa tipe data setiap kolom
print("\nTipe data setiap kolom:")
print(df.dtypes)

# Menghitung nilai kosong setiap kolom
print("\nJumlah nilai kosong setiap kolom:")
print(df.isnull().sum())

# Memeriksa jumlah pesanan berdasarkan status
print("\nJumlah pesanan berdasarkan status:")
print(df["order_status"].value_counts())

# Memeriksa nilai kosong tanggal pengiriman berdasarkan status
print("\nNilai kosong tanggal pengiriman berdasarkan status:")
print(
    df.groupby("order_status")[
        ["order_approved_at", "order_delivered_carrier_date",
         "order_delivered_customer_date"]
    ].agg(lambda kolom: kolom.isna().sum())
)

# Statistik durasi pengiriman
print("\nStatistik durasi pengiriman (hari):")
print(df["delivery_duration_days"].describe())

# Memeriksa durasi negatif
negative_duration = df[df["delivery_duration_days"] < 0]

print("\nJumlah durasi pengiriman negatif:")
print(len(negative_duration))

# Memeriksa 10 pesanan dengan durasi pengiriman terlama
print("\n10 pesanan dengan durasi pengiriman terlama:")

print(
    df.nlargest(10, "delivery_duration_days")[
        [
            "order_id",
            "order_status",
            "order_purchase_timestamp",
            "order_delivered_customer_date",
            "delivery_duration_days",
        ]
    ].to_string(index=False)
)

# Menghitung keterlambatan pengiriman dalam hari
df["delivery_delay_days"] = (
    df["order_delivered_customer_date"]
    - df["order_estimated_delivery_date"]
).dt.total_seconds() / 86400

# Memeriksa 10 pesanan dengan keterlambatan terbesar
print("\n10 pesanan dengan keterlambatan terbesar:")

print(
    df.nlargest(10, "delivery_delay_days")[
        [
            "order_id",
            "order_purchase_timestamp",
            "order_delivered_customer_date",
            "order_estimated_delivery_date",
            "delivery_delay_days",
        ]
    ].to_string(index=False)
)