{% snapshot HIST_MICROPAY_EMPLOYEE_LEAVE %}

{{
    config(
        unique_key="IDEMPLOYEELEAVE||'-'||COALESCE(POSTENTDATE,'1900-01-01')",
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
QUALIFY ROW_NUMBER() OVER (PARTITION BY IDEMPLOYEELEAVE,POSTENTDATE ORDER BY _AIRBYTE_GENERATION_ID DESC) = 1

{% endsnapshot %}