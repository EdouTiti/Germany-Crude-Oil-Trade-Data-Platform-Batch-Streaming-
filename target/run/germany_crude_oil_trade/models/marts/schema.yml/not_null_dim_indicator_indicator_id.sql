
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select indicator_id
from `zoomcampde2026`.`Germany_oil_analytics`.`dim_indicator`
where indicator_id is null



  
  
      
    ) dbt_internal_test