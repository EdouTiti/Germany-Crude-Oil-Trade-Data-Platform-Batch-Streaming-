
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select year
from `zoomcampde2026`.`Germany_oil_analytics`.`stg_germany_crude_oil_imports`
where year is null



  
  
      
    ) dbt_internal_test