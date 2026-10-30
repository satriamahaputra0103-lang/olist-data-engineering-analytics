select i.order_id
from {{ ref('stg_order_items') }} i
left join {{ ref('stg_orders') }} o
    on i.order_id = o.order_id
where o.order_id is null