
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select hs_code
from `zoomcampde2026`.`Germany_oil_data`.`global_oil_trade_clean`
where hs_code is null



  
  
      
    ) dbt_internal_test