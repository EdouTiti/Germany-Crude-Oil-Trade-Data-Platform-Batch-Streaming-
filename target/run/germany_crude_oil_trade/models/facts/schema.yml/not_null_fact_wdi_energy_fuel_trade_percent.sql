
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select fuel_trade_percent
from `zoomcampde2026`.`Germany_oil_analytics`.`fact_wdi_energy`
where fuel_trade_percent is null



  
  
      
    ) dbt_internal_test