{% snapshot HIST_BETTER_IMPACT_VOLUNTEER_INFORMATION %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='BETTER_IMPACT',
        unique_key='DATABASEUSERID',
        strategy='check',
        check_cols=[
            'FIRSTNAME',
            'LASTNAME',
            'POSTALCODE',
            'BIRTHDAY',
            'VOLUNTEERDATEJOINED',
            'VOLUNTEERSTATUS',
            'DATEOFLASTVOLUNTEERSTATUSCHANGE',
            '"CF - About you - Please indicate your gender"',
            '"CF - Special needs groups (this information is requested by the Dept. of Health) - Does the recipient identify as being from a special needs group?"',
            '"CF - Special needs groups (this information is requested by the Dept. of Health) - If more than one special need applies please list here"'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_better_impact', 'VOLUNTEER_INFORMATION') }}

{% endsnapshot %}