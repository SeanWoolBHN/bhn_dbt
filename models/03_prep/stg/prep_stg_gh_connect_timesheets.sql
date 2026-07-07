SELECT
    {{ format_name('CLIENTS') }}                  AS FULL_NAME,
    TRIM(START_TIME)                              AS START_TS,
    TRIM(TOTAL_TIME)                              AS DURATION,
    TRIM(CASE_NUMBER)                             AS CASE_NO,
    TRIM(DIRECT_TIME)                             AS DIRECT_TIME,
    TRIM(TRAVEL_TIME)                             AS TRAVEL_TIME,
    TRIM(CASE_SUB_TYPE)                           AS CASE_SUB_TYPE,
    TRIM(INDIRECT_TIME)                           AS INDIRECT_TIME,
    {{ format_name('ACTIVITY_TITLE') }}           AS ACTIVITY_TITLE,
    {{ format_name('TIMESHEET_STAFF') }}          AS TIMESHEET_STAFF_FULL_NAME,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_GH_CONNECT_TIMESHEETS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')