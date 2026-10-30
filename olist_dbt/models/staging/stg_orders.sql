with source_data as (

    select
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        delivery_duration_days,
        delivery_delay_days
    from {{ source('olist', 'olist_orders') }}

),

classified as (

    select
        *,
        case
            when order_delivered_carrier_date is null
              or order_delivered_customer_date is null
                then 'incomplete'

            when order_delivered_carrier_date < order_purchase_timestamp
              or order_delivered_customer_date < order_delivered_carrier_date
                then 'anomalous'

            else 'valid'
        end as delivery_sequence_status
    from source_data

)

select
    *,
    delivery_sequence_status = 'valid'
        as is_delivery_sequence_valid
from classified