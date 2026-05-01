
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select origin_country_id
from `zoomcampde2026`.`Germany_oil_data`.`global_oil_trade_clean`
where origin_country_id is null



  
  
      
    ) dbt_internal_test