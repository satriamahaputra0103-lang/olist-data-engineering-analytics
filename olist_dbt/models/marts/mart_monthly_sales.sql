with delivered_orders as (

    select
        order_id,
        date_trunc('month', order_purchase_timestamp)::date
            as order_month
    from {{ ref('stg_orders') }}
    where order_status = 'delivered'

),

order_items as (

    select
        order_id,
        order_item_id,
        price,
        freight_value
    from {{ ref('stg_order_items') }}

)

select
    o.order_month,
    count(distinct o.order_id) as delivered_orders,
    count(i.order_item_id) as total_items,
    sum(i.price) as merchandise_value,
    sum(i.freight_value) as freight_value,
    sum(i.price + i.freight_value)
        as merchandise_plus_freight
from delivered_orders o
join order_items i
    on o.order_id = i.order_id
group by o.order_month
