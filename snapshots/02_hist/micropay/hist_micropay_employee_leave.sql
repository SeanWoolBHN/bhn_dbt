{% snapshot HIST_MICROPAY_EMPLOYEE_LEAVE %}

{{
    config(
        schema = 'MICROPAY',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'EMPCODE',
            'LEAVECODE',
            'LEAVETYPE',
            'TERMINATED',
            'POSTENTDATE',
            'POSTENTDAYS',
            'POSTENTHOURS',
            'IDEMPLOYEELEAVE',
            '_AB_SOURCE_FILE_URL',
            '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_micropay', 'EMPLOYEE_LEAVE') }}

{% endsnapshot %}