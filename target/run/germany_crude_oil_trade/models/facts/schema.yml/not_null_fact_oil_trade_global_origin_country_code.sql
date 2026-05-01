
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select origin_country_code
from `zoomcampde2026`.`Germany_oil_analytics`.`fact_oil_trade_global`
where origin_country_code is null



  
  
      
    ) dbt_internal_test