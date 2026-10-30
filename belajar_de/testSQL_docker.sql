SELECT
    current_database() AS nama_database,
    current_user AS pengguna,
    version() AS versi_postgresql;

-- 1. Memeriksa jumlah baris
SELECT COUNT(*) AS total_orders
FROM olist_orders;


-- 2. Memeriksa struktur dan contoh data
SELECT
    order_id,
    customer_id,
    order_status,
    delivery_duration_days,
    delivery_delay_days
FROM olist_orders
LIMIT 10;


-- 3. Memeriksa jumlah nilai NULL
SELECT
    COUNT(*) FILTER (
        WHERE order_approved_at IS NULL
    ) AS missing_approved_at,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS missing_delivered_date,

    COUNT(*) FILTER (
        WHERE delivery_duration_days IS NULL
    ) AS missing_delivery_duration,

    COUNT(*) FILTER (
        WHERE delivery_delay_days IS NULL
    ) AS missing_delivery_delay
FROM olist_orders;