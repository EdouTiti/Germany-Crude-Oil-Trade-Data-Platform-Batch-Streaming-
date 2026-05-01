with source as (
    select *
    from {{ source('oil_trade_warehouse', 'germany_crude_oil_imports_clean') }}
),

keyed as (
    select
        *,
        to_json_string(struct(
            year,
            country,
            country_id,
            partner,
            partner_id,
            partner2,
            commodity_description,
            quantity,
            quantity_unit,
            trade_value,
            trade_direction
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
    to_hex(md5(concat(duplicate_key, '#', cast(duplicate_sequence as string)))) as germany_import_record_id,
    year,
    country,
    cast(country_id as int64) as country_id,
    partner,
    cast(partner_id as int64) as partner_id,
    partner2,
    commodity_description,
    quantity,
    quantity_unit,
    trade_value,
    trade_direction
from numbered

