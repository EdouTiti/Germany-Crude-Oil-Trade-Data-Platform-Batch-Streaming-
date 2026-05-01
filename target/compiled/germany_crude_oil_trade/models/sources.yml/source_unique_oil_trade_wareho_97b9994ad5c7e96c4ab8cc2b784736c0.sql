
    
    

with dbt_test__target as (

  select country_id as unique_field
  from `zoomcampde2026`.`Germany_oil_data`.`country_name_mapping_clean`
  where country_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


