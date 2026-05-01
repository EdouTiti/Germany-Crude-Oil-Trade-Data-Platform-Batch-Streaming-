
  
    

    create or replace table `zoomcampde2026`.`Germany_oil_analytics`.`fct_global_trade_summary`
      
    
    

    
    OPTIONS()
    as (
      with trades as (
    select *
    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_global_oil_trade`
)

select
    year,
    month,
    export_country_id,
    export_country,
    origin_country_id,
    origin_country,
    hs_code,
    product_description,
    mode_of_transport,
    count(*) as trade_record_count,
    sum(total_packages) as total_packages,
    sum(quantity) as total_quantity,
    sum(gross_weight_kg) as total_gross_weight_kg,
    sum(net_weight_kg) as total_net_weight_kg,
    sum(total_value_usd) as total_value_usd
from trades
group by
    year,
    month,
    export_country_id,
    export_country,
    origin_country_id,
    origin_country,
    hs_code,
    product_description,
    mode_of_transport
    );
  