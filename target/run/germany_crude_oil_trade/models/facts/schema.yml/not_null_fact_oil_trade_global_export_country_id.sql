
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select export_country_id
from `zoomcampde2026`.`Germany_oil_analytics`.`fact_oil_trade_global`
where export_country_id is null



  
  
      
    ) dbt_internal_test