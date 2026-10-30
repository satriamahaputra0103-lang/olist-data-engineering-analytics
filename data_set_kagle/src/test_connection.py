from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine, text
import os

# Menentukan lokasi file .env di folder utama proyek
project_dir = Path(__file__).resolve().parents[2]
env_path = project_dir / ".env"

# Membaca konfigurasi dari file .env
load_dotenv(env_path)

# Mengambil URL koneksi dari environment variable
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError("DATABASE_URL tidak ditemukan di file .env")

# Membuat pengelola koneksi PostgreSQL
engine = create_engine(DATABASE_URL)

try:
    with engine.connect() as connection:
        result = connection.execute(text("SELECT version()"))

        print("Koneksi PostgreSQL berhasil!")
        print(result.scalar())

except Exception as error:
    print("Koneksi PostgreSQL gagal.")
    print(error)

finally:
    engine.dispose()