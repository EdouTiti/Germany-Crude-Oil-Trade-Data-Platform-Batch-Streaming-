
    
    

with dbt_test__target as (

  select wdi_fuel_trade_record_id as unique_field
  from `zoomcampde2026`.`Germany_oil_analytics`.`stg_wdi_fuel_trade`
  where wdi_fuel_trade_record_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


