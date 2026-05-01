
    
    

with all_values as (

    select
        trade_direction as value_field,
        count(*) as n_records

    from `zoomcampde2026`.`Germany_oil_data`.`wdi_fuel_trade_long`
    group by trade_direction

)

select *
from all_values
where value_field not in (
    'import','export'
)


