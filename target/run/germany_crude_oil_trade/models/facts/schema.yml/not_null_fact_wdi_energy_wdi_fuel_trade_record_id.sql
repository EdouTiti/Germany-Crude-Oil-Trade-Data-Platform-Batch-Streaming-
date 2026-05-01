
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select wdi_fuel_trade_record_id
from `zoomcampde2026`.`Germany_oil_analytics`.`fact_wdi_energy`
where wdi_fuel_trade_record_id is null



  
  
      
    ) dbt_internal_test