
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select partner_id
from `zoomcampde2026`.`Germany_oil_analytics`.`fct_germany_imports_by_partner_year`
where partner_id is null



  
  
      
    ) dbt_internal_test