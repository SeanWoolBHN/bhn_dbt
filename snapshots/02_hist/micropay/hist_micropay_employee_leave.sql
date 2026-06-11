{% snapshot HIST_MICROPAY_EMPLOYEE_LEAVE %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='MICROPAY',
        unique_key='IDEMPLOYEELEAVE',
        strategy='check',
        check_cols=[
            'EMPCODE',
            'TERMINATED',
            'LEAVETYPE',
            'LEAVECODE',
            'POSTENTDATE',
            'POSTENTHOURS',
            'POSTENTDAYS'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    IDEMPLOYEELEAVE,
    EMPCODE,
    TERMINATED,
    LEAVETYPE,
    LEAVECODE,
    POSTENTDATE,
    POSTENTHOURS,
    POSTENTDAYS,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_micropay', 'EMPLOYEE_LEAVE') }}

{% endsnapshot %}