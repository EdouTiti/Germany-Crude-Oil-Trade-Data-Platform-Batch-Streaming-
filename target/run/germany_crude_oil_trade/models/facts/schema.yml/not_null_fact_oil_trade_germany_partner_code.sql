
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select partner_code
from `zoomcampde2026`.`Germany_oil_analytics`.`fact_oil_trade_germany`
where partner_code is null



  
  
      
    ) dbt_internal_test