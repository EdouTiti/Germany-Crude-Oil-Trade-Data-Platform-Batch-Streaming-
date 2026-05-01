
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        trade_direction as value_field,
        count(*) as n_records

    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_wdi_fuel_trade`
    group by trade_direction

)

select *
from all_values
where value_field not in (
    'import','export'
)



  
  
      
    ) dbt_internal_test