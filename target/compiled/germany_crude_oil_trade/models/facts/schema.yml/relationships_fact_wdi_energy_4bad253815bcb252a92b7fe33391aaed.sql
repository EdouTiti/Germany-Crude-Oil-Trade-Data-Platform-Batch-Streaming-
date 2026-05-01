
    
    

with child as (
    select indicator_id as from_field
    from `zoomcampde2026`.`Germany_oil_analytics`.`fact_wdi_energy`
    where indicator_id is not null
),

parent as (
    select indicator_id as to_field
    from `zoomcampde2026`.`Germany_oil_analytics`.`dim_indicator`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


