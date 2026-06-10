{% snapshot hist_better_impact_profile %}

{{
    config(
        unique_key='database_user_id',
        strategy='check',
        check_cols='all',
        invalidate_hard_deletes=True
    )
}}

SELECT * FROM {{ ref('stg_better_impact_profile') }}

{% endsnapshot %}