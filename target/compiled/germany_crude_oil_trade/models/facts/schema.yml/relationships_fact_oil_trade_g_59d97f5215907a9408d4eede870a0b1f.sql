
    
    

with child as (
    select country_code as from_field
    from `zoomcampde2026`.`Germany_oil_analytics`.`fact_oil_trade_germany`
    where country_code is not null
),

parent as (
    select country_code as to_field
    from `zoomcampde2026`.`Germany_oil_analytics`.`dim_country`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


