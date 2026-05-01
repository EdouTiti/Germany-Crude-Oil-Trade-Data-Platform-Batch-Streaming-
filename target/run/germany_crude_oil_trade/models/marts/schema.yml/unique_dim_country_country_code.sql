
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with dbt_test__target as (

  select country_code as unique_field
  from `zoomcampde2026`.`Germany_oil_analytics`.`dim_country`
  where country_code is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1



  
  
      
    ) dbt_internal_test