
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select total_value_usd
from `zoomcampde2026`.`Germany_oil_analytics`.`fct_global_trade_summary`
where total_value_usd is null



  
  
      
    ) dbt_internal_test