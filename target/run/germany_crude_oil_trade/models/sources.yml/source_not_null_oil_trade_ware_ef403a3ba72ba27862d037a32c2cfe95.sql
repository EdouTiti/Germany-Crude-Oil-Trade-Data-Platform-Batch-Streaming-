
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select partner_id
from `zoomcampde2026`.`Germany_oil_data`.`germany_crude_oil_imports_clean`
where partner_id is null



  
  
      
    ) dbt_internal_test