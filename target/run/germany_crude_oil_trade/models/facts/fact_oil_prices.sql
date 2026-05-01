
  
    

    create or replace table `zoomcampde2026`.`Germany_oil_analytics`.`fact_oil_prices`
      
    
    

    
    OPTIONS()
    as (
      with prices as (
    select *
    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_oil_prices`
)

select
    date,
    year,
    entity,
    entity_code,
    price_usd
from prices
    );
  