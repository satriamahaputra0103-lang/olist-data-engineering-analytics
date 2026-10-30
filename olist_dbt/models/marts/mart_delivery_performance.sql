select
    date_trunc('month', order_purchase_timestamp)::date
        as order_month,

    count(*) as delivered_orders,

    avg(delivery_duration_days)
        as avg_delivery_duration_days,

    percentile_cont(0.5) within group (
        order by delivery_duration_days
    ) as median_delivery_duration_days,

    avg(delivery_delay_days)
        as avg_delivery_delay_days,

    count(*) filter (
        where delivery_delay_days > 0
    ) as delayed_orders,

    count(*) filter (
        where delivery_delay_days <= 0
    ) as on_time_or_early_orders

from {{ ref('stg_orders') }}
where order_status = 'delivered'
  and is_delivery_sequence_valid = true
  and delivery_duration_days is not null
group by 1
