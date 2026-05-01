
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        trade_direction as value_field,
        count(*) as n_records

    from `zoomcampde2026`.`Germany_oil_data`.`germany_crude_oil_imports_clean`
    group by trade_direction

)

select *
from all_values
where value_field not in (
    'import'
)



  
  
      
    ) dbt_internal_test