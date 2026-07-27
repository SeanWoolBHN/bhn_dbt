{% snapshot HIST_SUPPORTABILITY_ACTIVITY_REPORT %}

{{
    config(
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            '"TO"', '"FROM"', 'SITE', 'TAGS', 'STAFF', 'CLIENTS',
            'PROGRAM', 'SERVICE', 'ACTIVITY', 'LOCATION', 'ACTIVITY_HOURS',
            'ACTIVITY_ID', 'ACTIVITY_SIGNED_OFF', 'REPLICATING_STAFF_NOTES',
            'REPLICATING_CLIENT_NOTES', 'STAFF_AVAILABILITY_ISSUES',
            'NON_REPLICATING_STAFF_NOTES', 'STAFF_POSITIONS_TO_BE_FILLED',
            'ACTIVITY_SIGN_OFF_DATE_TIME', 'ACTIVITY_SIGN_OFF_COMPLETED_BY',
            'ACTIVITY_TOTAL_NDIS_ALLOCATED_HOURS',
            'ACTIVITY_COMPLETE_NOT_YET_SIGNED_OFF',
            'INVOICES_CREATED_FOR_ONE_OR_MORE_CLIENTS',
            'TIMESHEETS_CREATED_FOR_ONE_OR_MORE_STAFF',
            'ACTIVITY_COMPLETE_TIMESHEETS_NOT_YET_SIGNED_OFF',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *

FROM {{ source('raw_supportability', 'ACTIVITY_REPORT') }}

{% endsnapshot %}