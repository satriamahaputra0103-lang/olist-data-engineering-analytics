# DATA & ANALYTICS REQUIREMENTS
## Olist Brazilian E-Commerce Data Engineering Project

### 1. Project Background

Proyek ini menggunakan dataset Olist Brazilian E-Commerce untuk membangun pipeline data yang mampu mengolah data transaksi e-commerce menjadi informasi yang siap digunakan untuk kebutuhan analisis bisnis.

Data transaksi dalam bentuk sumber mentah belum secara langsung memberikan gambaran analitis yang terintegrasi. Data pesanan, item pesanan, pembayaran, pengiriman, dan ulasan pelanggan memiliki struktur serta tingkat granularitas yang berbeda.

Oleh karena itu, diperlukan proses integrasi, transformasi, validasi, dan agregasi data untuk menghasilkan analytical data products yang konsisten dan dapat digunakan oleh Data Analyst.

### 2. Business Objectives

Tujuan analitik proyek ini adalah:

1. Menyediakan informasi mengenai performa penjualan dan tren transaksi.
2. Mengevaluasi performa pengiriman pesanan.
3. Memahami pengalaman dan kepuasan pelanggan berdasarkan ulasan.
4. Menyediakan data terstruktur untuk mendukung analisis dan visualisasi bisnis.
5. Memastikan data yang disajikan telah melalui proses validasi kualitas.

### 3. Business Questions

#### 3.1 Sales Performance
- Bagaimana perkembangan nilai penjualan setiap bulan?
- Bagaimana perubahan jumlah pesanan dari waktu ke waktu?
- Bagaimana perbandingan nilai merchandise dan biaya pengiriman?

#### 3.2 Delivery Performance
- Berapa rata-rata durasi pengiriman pesanan?
- Berapa jumlah pesanan yang terlambat dan tepat waktu?
- Bagaimana tren performa pengiriman setiap bulan?

#### 3.3 Customer Experience
- Bagaimana distribusi skor ulasan pelanggan?
- Berapa rata-rata skor ulasan setiap bulan?
- Bagaimana perkembangan ulasan positif dan negatif?

#### 3.4 Data Quality
- Apakah terdapat data pesanan dengan atribut penting yang kosong?
- Apakah terdapat ketidaksesuaian relasi antar tabel?
- Apakah terdapat ketidaksesuaian antara data pembayaran dan nilai pesanan?
- Apakah terdapat anomali pada urutan waktu transaksi dan pengiriman?

### 4. Dataset Selection Rationale

Dataset Olist Brazilian E-Commerce dipilih karena memiliki karakteristik yang mendukung pengembangan proyek Data Engineering dan analisis bisnis, yaitu:

1. Memiliki data transaksi e-commerce dengan jumlah observasi yang memadai.
2. Terdiri dari beberapa tabel yang saling berhubungan.
3. Memiliki atribut waktu yang memungkinkan analisis berdasarkan periode.
4. Memuat informasi item pesanan, pembayaran, pengiriman, dan ulasan pelanggan.
5. Memungkinkan penerapan proses ETL, data modeling, data quality testing, dan analytical reporting.

Dataset ini juga memberikan kesempatan untuk menerapkan proses transformasi dari data operasional menjadi data analitis.

### 5. Data Requirements

| Domain | Data yang dibutuhkan | Tujuan |
|---|---|---|
| Orders | Order ID, status, purchase date, delivery dates | Analisis transaksi dan pengiriman |
| Order Items | Product ID, seller ID, price, freight value | Analisis penjualan dan biaya pengiriman |
| Payments | Payment type, payment value, installments | Analisis pembayaran dan validasi nilai transaksi |
| Reviews | Review ID, order ID, review score, review date | Analisis pengalaman pelanggan |
| Customers | Customer ID, customer location | Analisis karakteristik pelanggan |
| Products | Product ID, category | Analisis kategori produk |
| Sellers | Seller ID, seller location | Analisis karakteristik penjual |
| Geolocation | Latitude, longitude, postal code | Potensi analisis geografis |
| Category Translation | Category name translation | Penyajian kategori produk |

### 6. Data Quality Requirements

Data yang digunakan harus melalui pemeriksaan kualitas, meliputi:

1. Pemeriksaan nilai kosong pada atribut penting.
2. Pemeriksaan keunikan primary key.
3. Pemeriksaan integritas relasi antar tabel.
4. Pemeriksaan konsistensi urutan tanggal transaksi dan pengiriman.
5. Pemeriksaan kesesuaian nilai pembayaran.
6. Identifikasi nilai atau kondisi transaksi yang tidak lazim.

Temuan kualitas data perlu diklasifikasikan berdasarkan tingkat keparahan, seperti ERROR, WARNING, dan INFO, agar pengguna dapat membedakan kegagalan validasi dari anomali yang masih memerlukan interpretasi.

### 7. Data Transformation Requirements

Data Engineer bertanggung jawab menyiapkan data melalui proses berikut:

1. Extract: mengambil data sumber dari file dataset Olist.
2. Load: memuat data ke PostgreSQL sebagai penyimpanan data sumber.
3. Staging: menstandarkan tipe data, nama atribut, dan struktur data.
4. Transformation: mengintegrasikan tabel yang relevan dan menghitung atribut turunan.
5. Aggregation: membentuk data berdasarkan periode dan kebutuhan analisis.
6. Testing: menjalankan pengujian kualitas dan integritas data.

Transformasi harus mempertahankan makna data sumber dan memastikan definisi metrik terdokumentasi.

### 8. Analytical Data Products

Hasil transformasi disediakan dalam bentuk tabel analitis:

| Data Product | Kebutuhan Analisis |
|---|---|
| mart_monthly_sales | Performa penjualan bulanan |
| mart_delivery_performance | Performa dan ketepatan waktu pengiriman |
| mart_customer_reviews | Pengalaman dan ulasan pelanggan |
| audit_data_quality | Temuan pemeriksaan kualitas data |

### 9. Dashboard Requirements

Dashboard diharapkan menyajikan informasi yang relevan untuk masing-masing domain:

**Sales Dashboard**
- Total Sales
- Total Orders
- Total Items Sold
- Monthly Sales Trend
- Monthly Orders Trend
- Merchandise vs Freight

**Delivery Dashboard**
- Average Delivery Duration
- Delayed Orders
- On-time Orders
- Monthly On-time vs Delayed Orders
- Average Delivery Duration Trend
- Monthly Delivered Orders

**Customer Experience Dashboard**
- Total Reviews
- Average Review Score
- Positive Reviews
- Monthly Reviews Trend
- Monthly Review Rating Distribution
- Average Review Score Trend

### 10. Acceptance Criteria

Proyek dianggap memenuhi kebutuhan awal apabila:

1. Data sumber berhasil dimuat ke PostgreSQL.
2. Model staging dan mart berhasil dibangun menggunakan dbt.
3. Pengujian kualitas data dapat dijalankan dan hasilnya terdokumentasi.
4. Pipeline dapat dieksekusi melalui Dagster.
5. Analytical data products dapat diakses oleh Apache Superset.
6. Dashboard dapat menampilkan metrik sesuai domain analisis.
7. Konfigurasi dan proses menjalankan proyek terdokumentasi.

### 11. Project Scope and Limitations

Proyek ini menggunakan dataset historis Olist Brazilian E-Commerce dan berfokus pada analisis penjualan, pengiriman, pengalaman pelanggan, serta kualitas data.

Analisis yang dihasilkan bersifat deskriptif berdasarkan data yang tersedia. Hasilnya tidak secara otomatis menjelaskan hubungan sebab-akibat atau menjamin bahwa seluruh kebutuhan operasional perusahaan telah tercakup.

Pengembangan analisis lanjutan dapat dilakukan dengan memanfaatkan data pelanggan, produk, penjual, pembayaran, dan geografis yang tersedia dalam dataset.
