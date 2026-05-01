
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select total_trade_value
from `zoomcampde2026`.`Germany_oil_analytics`.`fact_oil_trade_germany`
where total_trade_value is null



  
  
      
    ) dbt_internal_test