
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select global_trade_record_id
from `zoomcampde2026`.`Germany_oil_analytics`.`stg_global_oil_trade`
where global_trade_record_id is null



  
  
      
    ) dbt_internal_test