
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select trade_value
from `zoomcampde2026`.`Germany_oil_data`.`germany_crude_oil_imports_clean`
where trade_value is null



  
  
      
    ) dbt_internal_test