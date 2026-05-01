
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  with country_id_values as (
    select 'germany_crude_oil_imports_clean.country_id' as field_name, cast(country_id as string) as field_value
    from `zoomcampde2026`.`Germany_oil_data`.`germany_crude_oil_imports_clean`
    union all
    select 'germany_crude_oil_imports_clean.partner_id', cast(partner_id as string)
    from `zoomcampde2026`.`Germany_oil_data`.`germany_crude_oil_imports_clean`
    union all
    select 'global_oil_trade_clean.export_country_id', cast(export_country_id as string)
    from `zoomcampde2026`.`Germany_oil_data`.`global_oil_trade_clean`
    union all
    select 'global_oil_trade_clean.origin_country_id', cast(origin_country_id as string)
    from `zoomcampde2026`.`Germany_oil_data`.`global_oil_trade_clean`
    union all
    select 'country_name_mapping_clean.country_id', cast(country_id as string)
    from `zoomcampde2026`.`Germany_oil_data`.`country_name_mapping_clean`
    union all
    select 'wdi_fuel_trade_long.country_id', cast(country_id as string)
    from `zoomcampde2026`.`Germany_oil_data`.`wdi_fuel_trade_long`
)

select *
from country_id_values
where field_value is null
   or not regexp_contains(field_value, r'^[0-9]+$')
  
  
      
    ) dbt_internal_test