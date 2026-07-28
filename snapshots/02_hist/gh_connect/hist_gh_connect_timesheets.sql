{% snapshot HIST_GH_CONNECT_TIMESHEETS %}

{{
    config(
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'CLIENTS',
            'START_TIME',
            'TOTAL_TIME',
            'CASE_NUMBER',
            'DIRECT_TIME',
            'TRAVEL_TIME',
            'CASE_SUB_TYPE',
            'INDIRECT_TIME',
            'ACTIVITY_TITLE',
            'TIMESHEET_STAFF',
            '_AB_SOURCE_FILE_URL',
            '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
*
FROM {{ source('raw_gh_connect', 'TIMESHEETS') }}

{% endsnapshot %}