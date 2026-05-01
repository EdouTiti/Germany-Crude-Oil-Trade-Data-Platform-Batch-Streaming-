
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select commodity_id as from_field
    from `zoomcampde2026`.`Germany_oil_analytics`.`fact_oil_trade_germany`
    where commodity_id is not null
),

parent as (
    select commodity_id as to_field
    from `zoomcampde2026`.`Germany_oil_analytics`.`dim_commodity`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test