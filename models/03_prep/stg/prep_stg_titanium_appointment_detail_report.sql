SELECT
    TRIM(DR_)                                     AS DR_ID,
    TRIM(ROOM)                                     AS ROOM,
    LOWER(TRIM(EMAIL))                             AS EMAIL,
    {{ format_phone('PHONE') }}                    AS PHONE,
    {{ format_name('CLINIC') }}                    AS CLINIC,
    TRIM(SERVICE)                                  AS SERVICE,
    TRIM(CATEGORY)                                 AS CATEGORY,
    TRY_TO_NUMBER(TRIM(DURATION),18,6)             AS APPT_DURATION_HOURS,
    {{ format_name('LASTNAME') }}                  AS LAST_NAME,
    {{ format_name('CREATEDBY') }}                 AS CREATED_BY,
    {{ format_name('FIRSTNAME') }}                 AS FIRST_NAME,
    TRY_TO_NUMBER(TRIM(TEXTBOX81),18,6)            AS AGENCY_ID,
    {{ format_name('AGENCYNAME') }}                AS AGENCY_NAME,
    TRIM(APPTSTATUS)                               AS APPT_STATUS,
    TRIM(CANCELREASON)                             AS CANCEL_REASON,
    {{ format_date('LASTEDITDATE') }}              AS LAST_EDIT_DATE,
    {{ format_name('LASTEDITEDBY') }}              AS LAST_EDITED_BY,
    TRIM(PROVIDERCODE)                             AS PROVIDER_CODE,
    {{ format_date('APPOINTMENTDATE') }}           AS APPT_DATE,
    TRIM(APPOINTMENTTIME)                          AS APPT_TIME,
    TRIM(INDIGENOUSSTATUS)                         AS INDIGENOUS_STATUS,

    _AIRBYTE_EXTRACTED_AT                           AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TITANIUM_APPOINTMENT_DETAIL_REPORT') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')