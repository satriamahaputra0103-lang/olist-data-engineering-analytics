select r.order_id
from {{ ref('stg_order_reviews') }} r
left join {{ ref('stg_orders') }} o
    on r.order_id = o.order_id
where o.order_id is null