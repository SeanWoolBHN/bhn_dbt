{% snapshot hist_bps_search_result %}

{{
    config(
        target_schema='BEST_PRACTICE',
        unique_key='internal_id',
        strategy='check',
        check_cols='all',
        invalidate_hard_deletes=True
    )
}}

SELECT * FROM {{ ref('stg_bps_search_result') }}

{% endsnapshot %}