
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select total_value_usd
from `zoomcampde2026`.`Germany_oil_data`.`global_oil_trade_clean`
where total_value_usd is null



  
  
      
    ) dbt_internal_test