
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select germany_import_record_id
from `zoomcampde2026`.`Germany_oil_analytics`.`stg_germany_crude_oil_imports`
where germany_import_record_id is null



  
  
      
    ) dbt_internal_test