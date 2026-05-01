
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select country_id
from `zoomcampde2026`.`Germany_oil_analytics`.`stg_country_name_mapping`
where country_id is null



  
  
      
    ) dbt_internal_test