
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select indicator_code
from `zoomcampde2026`.`Germany_oil_data`.`wdi_fuel_trade_long`
where indicator_code is null



  
  
      
    ) dbt_internal_test