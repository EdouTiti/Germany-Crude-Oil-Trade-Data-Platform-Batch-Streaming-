
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  select *
from `zoomcampde2026`.`Germany_oil_analytics`.`stg_wdi_fuel_trade`
where year < 1960 or year > 2025
  
  
      
    ) dbt_internal_test