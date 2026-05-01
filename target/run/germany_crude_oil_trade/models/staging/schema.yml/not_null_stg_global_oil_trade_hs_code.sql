
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select hs_code
from `zoomcampde2026`.`Germany_oil_analytics`.`stg_global_oil_trade`
where hs_code is null



  
  
      
    ) dbt_internal_test