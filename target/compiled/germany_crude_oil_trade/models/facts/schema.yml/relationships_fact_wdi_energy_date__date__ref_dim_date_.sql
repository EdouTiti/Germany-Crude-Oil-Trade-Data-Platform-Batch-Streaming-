
    
    

with child as (
    select date as from_field
    from `zoomcampde2026`.`Germany_oil_analytics`.`fact_wdi_energy`
    where date is not null
),

parent as (
    select date as to_field
    from `zoomcampde2026`.`Germany_oil_analytics`.`dim_date`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


