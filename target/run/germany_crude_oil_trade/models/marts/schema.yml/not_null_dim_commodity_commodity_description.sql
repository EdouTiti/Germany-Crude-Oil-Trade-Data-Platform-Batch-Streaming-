
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select commodity_description
from `zoomcampde2026`.`Germany_oil_analytics`.`dim_commodity`
where commodity_description is null



  
  
      
    ) dbt_internal_test