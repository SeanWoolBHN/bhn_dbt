{% snapshot HIST_SUPPORTABILITY_ACTIVITY_REPORT %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='SUPPORTABILITY',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            '"TO"',
            '"FROM"',
            'SITE',
            'TAGS',
            'STAFF',
            'CLIENTS',
            'PROGRAM',
            'SERVICE',
            'ACTIVITY',
            'LOCATION',
            '"ACTIVITY HOURS"',
            '"ACTIVITY SIGNED OFF"',
            '"REPLICATING STAFF NOTES"',
            '"REPLICATING CLIENT NOTES"',
            '"STAFF AVAILABILITY ISSUES"',
            '"NON-REPLICATING STAFF NOTES"',
            '"STAFF POSITIONS TO BE FILLED"',
            '"ACTIVITY SIGN OFF DATE & TIME"',
            '"ACTIVITY SIGN OFF COMPLETED BY"',
            '"ACTIVITY TOTAL NDIS ALLOCATED HOURS"',
            '"ACTIVITY COMPLETE, NOT YET SIGNED OFF"',
            '"INVOICES CREATED FOR ONE OR MORE CLIENTS"',
            '"TIMESHEETS CREATED FOR ONE OR MORE STAFF"',
            '"ACTIVITY COMPLETE, TIMESHEETS NOT YET SIGNED OFF"',
            '_AB_SOURCE_FILE_URL',
            '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    _AIRBYTE_RAW_ID,
    _AIRBYTE_EXTRACTED_AT,
    _AIRBYTE_META,
    _AIRBYTE_GENERATION_ID,
    "TO",
    "FROM",
    SITE,
    TAGS,
    STAFF,
    CLIENTS,
    PROGRAM,
    SERVICE,
    ACTIVITY,
    LOCATION,
    "ACTIVITY HOURS",
    "ACTIVITY SIGNED OFF",
    _AB_SOURCE_FILE_URL,
    "REPLICATING STAFF NOTES",
    "REPLICATING CLIENT NOTES",
    "STAFF AVAILABILITY ISSUES",
    "NON-REPLICATING STAFF NOTES",
    "STAFF POSITIONS TO BE FILLED",
    "ACTIVITY SIGN OFF DATE & TIME",
    _AB_SOURCE_FILE_LAST_MODIFIED,
    "ACTIVITY SIGN OFF COMPLETED BY",
    "ACTIVITY TOTAL NDIS ALLOCATED HOURS",
    "ACTIVITY COMPLETE, NOT YET SIGNED OFF",
    "INVOICES CREATED FOR ONE OR MORE CLIENTS",
    "TIMESHEETS CREATED FOR ONE OR MORE STAFF",
    "ACTIVITY COMPLETE, TIMESHEETS NOT YET SIGNED OFF",
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_supportability', 'ACTIVITY_REPORT') }}

{% endsnapshot %}