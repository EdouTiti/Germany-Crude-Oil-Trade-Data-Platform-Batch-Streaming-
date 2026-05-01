
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select price_usd
from `zoomcampde2026`.`Germany_oil_data`.`crude_oil_prices_clean`
where price_usd is null



  
  
      
    ) dbt_internal_test