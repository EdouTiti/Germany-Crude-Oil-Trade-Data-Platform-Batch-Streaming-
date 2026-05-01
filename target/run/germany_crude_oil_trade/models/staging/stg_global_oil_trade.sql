

  create or replace view `zoomcampde2026`.`Germany_oil_analytics`.`stg_global_oil_trade`
  OPTIONS()
  as with source as (
    select *
    from `zoomcampde2026`.`Germany_oil_data`.`global_oil_trade_clean`
),

keyed as (
    select
        *,
        to_json_string(struct(
            date,
            importer_name,
            supplier_name,
            export_country,
            export_country_id,
            origin_country,
            origin_country_id,
            hs_code,
            product_description,
            quantity,
            total_value_usd,
            currency,
            delivery_terms,
            mode_of_transport,
            port_of_unloading
        )) as duplicate_key
    from source
),

numbered as (
    select
        *,
        row_number() over (
            partition by duplicate_key
            order by duplicate_key
        ) as duplicate_sequence
    from keyed
)

select
    to_hex(md5(concat(duplicate_key, '#', cast(duplicate_sequence as string)))) as global_trade_record_id,
    date,
    importer_name,
    supplier_name,
    export_country,
    cast(export_country_id as int64) as export_country_id,
    origin_country,
    cast(origin_country_id as int64) as origin_country_id,
    hs_code,
    product_description,
    package_unit_name,
    unit,
    total_packages,
    quantity,
    gross_weight_kg,
    net_weight_kg,
    currency,
    total_value_usd,
    delivery_terms,
    mode_of_transport,
    port_of_unloading,
    chapter,
    heading,
    sub_heading,
    month,
    year
from numbered;

