
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select date
from `zoomcampde2026`.`Germany_oil_analytics`.`stg_oil_prices`
where date is null



  
  
      
    ) dbt_internal_test