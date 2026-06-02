{% snapshot hist_better_impact_feedback %}

{{
    config(
        unique_key='feedback_key',
        strategy='check',
        check_cols='all',
        invalidate_hard_deletes=True
    )
}}

SELECT * FROM {{ ref('stg_better_impact_feedback') }}

{% endsnapshot %}