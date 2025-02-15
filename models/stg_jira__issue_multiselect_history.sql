
with base as (

    select * 
    from {{ ref('stg_jira__issue_multiselect_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__issue_multiselect_history_tmp')),
                staging_columns=get_issue_multiselect_history_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_id,
        cast(field_id as {{ dbt_utils.type_string() }}) as field_id,
        issue_id,
        {% if target.type == 'snowflake' %}
        "TIME"
        {% elif target.type == 'redshift' %}
        "time"
        {% else %}
        time
        {% endif %} as updated_at,
        value as field_value,
        _fivetran_synced
        
    from fields
)

select * from final
