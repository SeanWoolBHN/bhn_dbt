{% snapshot HIST_SUPPORTABILITY_ACTIVITY_REPORT %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='SUPPORTABILITY',
        unique_key='ACTIVITY_ID',
        strategy='check',
        check_cols=[
            '"From"',
            '"To"',
            'ACTIVITY_HOURS',
            'ACTIVITY_TOTAL_NDIS_ALLOCATED_HOURS',
            'SITE',
            'SERVICE',
            'ACTIVITY',
            'PROGRAM',
            'LOCATION',
            'CLIENTS',
            'STAFF',
            'ACTIVITY_SIGNED_OFF',
            '"Activity Sign Off Date & Time"',
            'ACTIVITY_SIGN_OFF_COMPLETED_BY',
            '"Activity complete, not yet Signed Off"',
            '"Activity complete, Timesheets not yet Signed Off"',
            'STAFF_POSITIONS_TO_BE_FILLED',
            'STAFF_AVAILABILITY_ISSUES',
            'INVOICES_CREATED_FOR_ONE_OR_MORE_CLIENTS',
            'TIMESHEETS_CREATED_FOR_ONE_OR_MORE_STAFF',
            'TAGS',
            '"Non-Replicating Staff Notes"',
            'REPLICATING_STAFF_NOTES',
            'REPLICATING_CLIENT_NOTES'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    ACTIVITY_ID,
    "From",
    "To",
    ACTIVITY_HOURS,
    ACTIVITY_TOTAL_NDIS_ALLOCATED_HOURS,
    SITE,
    SERVICE,
    ACTIVITY,
    PROGRAM,
    LOCATION,
    CLIENTS,
    STAFF,
    ACTIVITY_SIGNED_OFF,
    "Activity Sign Off Date & Time",
    ACTIVITY_SIGN_OFF_COMPLETED_BY,
    "Activity complete, not yet Signed Off",
    "Activity complete, Timesheets not yet Signed Off",
    STAFF_POSITIONS_TO_BE_FILLED,
    STAFF_AVAILABILITY_ISSUES,
    INVOICES_CREATED_FOR_ONE_OR_MORE_CLIENTS,
    TIMESHEETS_CREATED_FOR_ONE_OR_MORE_STAFF,
    TAGS,
    "Non-Replicating Staff Notes",
    REPLICATING_STAFF_NOTES,
    REPLICATING_CLIENT_NOTES,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_supportability', 'ACTIVITY_REPORT') }}

{% endsnapshot %}