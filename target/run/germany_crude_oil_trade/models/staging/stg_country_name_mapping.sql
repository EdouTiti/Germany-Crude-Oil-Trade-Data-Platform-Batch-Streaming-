

  create or replace view `zoomcampde2026`.`Germany_oil_analytics`.`stg_country_name_mapping`
  OPTIONS()
  as with source as (
    select *
    from `zoomcampde2026`.`Germany_oil_data`.`country_name_mapping_clean`
)

select
    cast(country_id as int64) as country_id,
    trim(country_name) as country_name,
    trim(short_name) as short_name
from source;

