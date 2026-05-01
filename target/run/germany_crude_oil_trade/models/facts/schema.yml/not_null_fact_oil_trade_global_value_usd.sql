
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select value_usd
from `zoomcampde2026`.`Germany_oil_analytics`.`fact_oil_trade_global`
where value_usd is null



  
  
      
    ) dbt_internal_test