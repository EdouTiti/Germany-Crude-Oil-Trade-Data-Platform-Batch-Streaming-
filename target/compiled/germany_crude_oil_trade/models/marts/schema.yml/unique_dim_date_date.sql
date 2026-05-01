
    
    

with dbt_test__target as (

  select date as unique_field
  from `zoomcampde2026`.`Germany_oil_analytics`.`dim_date`
  where date is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


