
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select country_id
from `zoomcampde2026`.`Germany_oil_analytics`.`fct_wdi_fuel_trade_by_country_year`
where country_id is null



  
  
      
    ) dbt_internal_test