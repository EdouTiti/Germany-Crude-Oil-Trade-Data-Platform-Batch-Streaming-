
  
    

    create or replace table `zoomcampde2026`.`Germany_oil_analytics`.`fact_wdi_energy`
      
    
    

    
    OPTIONS()
    as (
      with fuel_trade as (
    select *
    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_wdi_fuel_trade`
)

select
    wdi_fuel_trade_record_id,
    country_id,
    country_id as country_code,
    date(year, 1, 1) as date,
    year,
    to_hex(md5(indicator_code)) as indicator_id,
    trade_direction,
    fuel_trade_percent
from fuel_trade
    );
  