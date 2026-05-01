
  
    

    create or replace table `zoomcampde2026`.`Germany_oil_analytics`.`fact_oil_trade_global`
      
    
    

    
    OPTIONS()
    as (
      with trades as (
    select *
    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_global_oil_trade`
)

select
    global_trade_record_id,
    date,
    year,
    importer_name,
    supplier_name,
    export_country_id,
    export_country_id as export_country_code,
    origin_country_id,
    origin_country_id as origin_country_code,
    to_hex(md5(to_json_string(struct(
        coalesce(hs_code, ''),
        coalesce(product_description, '')
    )))) as commodity_id,
    package_unit_name,
    unit,
    total_packages,
    quantity,
    gross_weight_kg,
    net_weight_kg,
    currency,
    total_value_usd as value_usd,
    delivery_terms,
    mode_of_transport,
    port_of_unloading
from trades
    );
  