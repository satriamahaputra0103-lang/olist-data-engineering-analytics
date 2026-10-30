select *
from {{ ref('stg_orders') }}
where
    (
        delivery_sequence_status = 'valid'
        and (
            order_delivered_carrier_date is null
            or order_delivered_customer_date is null
            or order_delivered_carrier_date < order_purchase_timestamp
            or order_delivered_customer_date < order_delivered_carrier_date
        )
    )
    or (
        delivery_sequence_status = 'anomalous'
        and not (
            order_delivered_carrier_date < order_purchase_timestamp
            or order_delivered_customer_date < order_delivered_carrier_date
        )
    )
    or (
        delivery_sequence_status = 'incomplete'
        and order_delivered_carrier_date is not null
        and order_delivered_customer_date is not null
    )
    or (
        is_delivery_sequence_valid
        is distinct from (delivery_sequence_status = 'valid')
    )