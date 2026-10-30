
{{
    config(
        materialized='table'
    )
}}

WITH

-- =========================================================
-- 1. AGREGASI ITEM DAN PEMBAYARAN SECARA TERPISAH
-- =========================================================

item_summary AS (
    SELECT
        order_id,
        COUNT(*) AS item_rows,
        SUM(price) AS total_item_price,
        SUM(freight_value) AS total_freight,
        SUM(price + freight_value) AS expected_total
    FROM public.olist_order_items
    GROUP BY order_id
),

payment_summary AS (
    SELECT
        order_id,
        COUNT(*) AS payment_rows,
        SUM(payment_value) AS total_payment
    FROM public.olist_order_payments
    GROUP BY order_id
),

-- =========================================================
-- 2. AUDIT KONSISTENSI TRANSAKSI PER PESANAN
-- =========================================================

transaction_audit AS (
    SELECT
        o.order_id,
        o.order_status,
        i.item_rows,
        p.payment_rows,
        i.expected_total,
        p.total_payment,
        CASE
            WHEN i.order_id IS NULL
                THEN 'NO_ITEM'
            WHEN p.order_id IS NULL
                THEN 'NO_PAYMENT'
            WHEN ABS(p.total_payment - i.expected_total) > 0.01
                THEN 'MISMATCH'
            ELSE 'MATCH'
        END AS transaction_status
    FROM public.olist_orders o
    LEFT JOIN item_summary i
        ON o.order_id = i.order_id
    LEFT JOIN payment_summary p
        ON o.order_id = p.order_id
),

transaction_counts AS (
    SELECT
        COUNT(*) FILTER (
            WHERE transaction_status = 'MISMATCH'
        )::bigint AS mismatch_count,

        COUNT(*) FILTER (
            WHERE transaction_status = 'NO_ITEM'
        )::bigint AS no_item_count,

        COUNT(*) FILTER (
            WHERE transaction_status = 'NO_PAYMENT'
        )::bigint AS no_payment_count
    FROM transaction_audit
),

-- =========================================================
-- 3. AUDIT KUALITAS DATA
-- =========================================================

audit_results AS (

    -- ORDERS: KUNCI DAN RELASI PELANGGAN

    SELECT
        'orders' AS dataset,
        'order_id_null' AS check_name,
        'ERROR' AS severity,
        COUNT(*)::bigint AS issue_count
    FROM public.olist_orders
    WHERE order_id IS NULL

    UNION ALL

    SELECT
        'orders',
        'duplicate_order_id',
        'ERROR',
        (COUNT(*) - COUNT(DISTINCT order_id))::bigint
    FROM public.olist_orders

    UNION ALL

    SELECT
        'orders',
        'customer_id_null',
        'ERROR',
        COUNT(*)::bigint
    FROM public.olist_orders
    WHERE customer_id IS NULL

    UNION ALL

    SELECT
        'orders',
        'customer_not_found',
        'ERROR',
        COUNT(*)::bigint
    FROM public.olist_orders o
    LEFT JOIN public.olist_customers c
        ON o.customer_id = c.customer_id
    WHERE o.customer_id IS NOT NULL
      AND c.customer_id IS NULL

    -- ORDER ITEMS: KUNCI, NILAI, DAN RELASI

    UNION ALL

    SELECT
        'order_items',
        'duplicate_composite_key',
        'ERROR',
        (
            COUNT(*) -
            COUNT(DISTINCT (order_id, order_item_id))
        )::bigint
    FROM public.olist_order_items

    UNION ALL

    SELECT
        'order_items',
        'negative_price',
        'ERROR',
        COUNT(*)::bigint
    FROM public.olist_order_items
    WHERE price < 0

    UNION ALL

    SELECT
        'order_items',
        'negative_freight',
        'ERROR',
        COUNT(*)::bigint
    FROM public.olist_order_items
    WHERE freight_value < 0

    UNION ALL

    SELECT
        'order_items',
        'zero_freight',
        'INFO',
        COUNT(*)::bigint
    FROM public.olist_order_items
    WHERE freight_value = 0

    UNION ALL

    SELECT
        'order_items',
        'order_not_found',
        'ERROR',
        COUNT(*)::bigint
    FROM public.olist_order_items i
    LEFT JOIN public.olist_orders o
        ON i.order_id = o.order_id
    WHERE i.order_id IS NOT NULL
      AND o.order_id IS NULL

    UNION ALL

    SELECT
        'order_items',
        'product_not_found',
        'ERROR',
        COUNT(*)::bigint
    FROM public.olist_order_items i
    LEFT JOIN public.olist_products p
        ON i.product_id = p.product_id
    WHERE i.product_id IS NOT NULL
      AND p.product_id IS NULL

    UNION ALL

    SELECT
        'order_items',
        'seller_not_found',
        'ERROR',
        COUNT(*)::bigint
    FROM public.olist_order_items i
    LEFT JOIN public.olist_sellers s
        ON i.seller_id = s.seller_id
    WHERE i.seller_id IS NOT NULL
      AND s.seller_id IS NULL

    -- PAYMENTS: KUNCI DAN NILAI

    UNION ALL

    SELECT
        'payments',
        'duplicate_composite_key',
        'ERROR',
        (
            COUNT(*) -
            COUNT(DISTINCT (order_id, payment_sequential))
        )::bigint
    FROM public.olist_order_payments

    UNION ALL

    SELECT
        'payments',
        'negative_payment',
        'ERROR',
        COUNT(*)::bigint
    FROM public.olist_order_payments
    WHERE payment_value < 0

    UNION ALL

    SELECT
        'payments',
        'zero_payment',
        'INFO',
        COUNT(*)::bigint
    FROM public.olist_order_payments
    WHERE payment_value = 0

    UNION ALL

    SELECT
        'payments',
        'order_not_found',
        'ERROR',
        COUNT(*)::bigint
    FROM public.olist_order_payments p
    LEFT JOIN public.olist_orders o
        ON p.order_id = o.order_id
    WHERE p.order_id IS NOT NULL
      AND o.order_id IS NULL

    -- REVIEWS: SKOR, KUNCI, DAN RELASI

    UNION ALL

    SELECT
        'reviews',
        'invalid_score',
        'ERROR',
        COUNT(*)::bigint
    FROM public.olist_order_reviews
    WHERE review_score IS NULL
       OR review_score NOT BETWEEN 1 AND 5

    UNION ALL

    SELECT
        'reviews',
        'duplicate_review_order_pair',
        'ERROR',
        (
            COUNT(*) -
            COUNT(DISTINCT (review_id, order_id))
        )::bigint
    FROM public.olist_order_reviews

    UNION ALL

    SELECT
        'reviews',
        'order_not_found',
        'ERROR',
        COUNT(*)::bigint
    FROM public.olist_order_reviews r
    LEFT JOIN public.olist_orders o
        ON r.order_id = o.order_id
    WHERE r.order_id IS NOT NULL
      AND o.order_id IS NULL

    -- ORDERS: ANOMALI URUTAN TANGGAL

    UNION ALL

    SELECT
        'orders',
        'carrier_before_purchase',
        'WARNING',
        COUNT(*)::bigint
    FROM public.olist_orders
    WHERE order_delivered_carrier_date < order_purchase_timestamp

    UNION ALL

    SELECT
        'orders',
        'customer_before_carrier',
        'WARNING',
        COUNT(*)::bigint
    FROM public.olist_orders
    WHERE order_delivered_customer_date < order_delivered_carrier_date

    UNION ALL

    SELECT
        'orders',
        'delivered_missing_delivery_date',
        'WARNING',
        COUNT(*)::bigint
    FROM public.olist_orders
    WHERE order_status = 'delivered'
      AND (
          order_delivered_carrier_date IS NULL
          OR order_delivered_customer_date IS NULL
      )

    -- TRANSAKSI: SELISIH NILAI

    UNION ALL

    SELECT
        'transactions',
        'payment_mismatch',
        'WARNING',
        mismatch_count
    FROM transaction_counts

    UNION ALL

    SELECT
        'transactions',
        'order_without_items',
        'INFO',
        no_item_count
    FROM transaction_counts

    UNION ALL

    SELECT
        'transactions',
        'order_without_payment',
        'WARNING',
        no_payment_count
    FROM transaction_counts
)

-- =========================================================
-- 4. OUTPUT AUDIT
-- =========================================================

SELECT
    dataset,
    check_name,
    severity,
    issue_count,
    CASE
        WHEN issue_count = 0
            THEN 'OK'
        WHEN severity = 'INFO'
            THEN 'DICATAT'
        ELSE 'PERLU DITINJAU'
    END AS audit_status,
    CURRENT_TIMESTAMP AS audited_at
FROM audit_results
ORDER BY
    CASE severity
        WHEN 'ERROR' THEN 1
        WHEN 'WARNING' THEN 2
        WHEN 'INFO' THEN 3
        ELSE 4
    END,
    dataset,
    check_name
