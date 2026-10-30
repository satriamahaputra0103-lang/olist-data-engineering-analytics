with reviews as (

    select
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        nullif(trim(review_creation_date), '')::timestamp
            as review_creation_timestamp
    from {{ ref('stg_order_reviews') }}

)

select
    date_trunc('month', review_creation_timestamp)::date
        as review_month,
    count(*) as total_reviews,
    count(*) filter (
        where review_score = 5
    ) as five_star_reviews,
    count(*) filter (
        where review_score = 4
    ) as four_star_reviews,
    count(*) filter (
        where review_score = 3
    ) as three_star_reviews,
    count(*) filter (
        where review_score = 2
    ) as two_star_reviews,
    count(*) filter (
        where review_score = 1
    ) as one_star_reviews,
    round(avg(review_score)::numeric, 2)
        as average_review_score,
    round(
        100.0 * count(*) filter (
            where review_score >= 4
        ) / nullif(count(*), 0),
        2
    ) as positive_review_percentage
from reviews
where review_score between 1 and 5
  and review_creation_timestamp is not null
group by 1
