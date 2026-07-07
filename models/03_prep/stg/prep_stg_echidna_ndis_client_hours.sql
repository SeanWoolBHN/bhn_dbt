SELECT
    TRIM("TO")                                   AS APPT_END_TIME,
    {{ format_date('"DATE"') }}                  AS APPT_DATE,
    TRIM("FROM")                                 AS APPT_START_TIME,
    TRIM(RATE)                                   AS RATE,
    TRIM(HOURS)                                  AS HOURS,
    TRIM(VALUE)                                  AS VALUE,
    TRIM(HOURS2)                                 AS HOURS_2,
    {{ format_name('REGION') }}                  AS REGION,
    TRIM(FUNDING)                                AS FUNDING,
    TRY_TO_NUMBER(TRIM(ITEM_NO),18,6)            AS ITEM_NO,
    TRY_TO_NUMBER(TRIM(NDIS_NO),18,6)            AS NDIS_NO,
    TRIM(ACTIVITY)                               AS ACTIVITY,
    TRIM(CLIENT_ID)                              AS ECHIDNA_CLIENT_ID,
    {{ format_name('CONSULTANT') }}              AS CONSULTANT_FULL_NAME,
    TRY_TO_NUMBER(TRIM(INVOICE_NO),18,6)         AS INVOICE_NO,
    TRIM(STAFF_TYPE)                             AS STAFF_TYPE,
    TRY_TO_NUMBER(TRIM(AMOUNT_PAID),18,6)        AS AMOUNT_PAID,
    {{ format_name('CLIENT_NAME') }}             AS FIRST_NAME,
    TRIM(HOURS_SPENT)                            AS HOURS_SPENT,
    TRY_TO_NUMBER(TRIM(CONSULTANT_ID),18,6)      AS CONSULTANT_ID,
    TRY_TO_NUMBER(TRIM(NDIS_CLAIM_NO),18,6)      AS NDIS_CLAIM_NO,
    {{ format_name('CLIENT_SURNAME') }}          AS LAST_NAME,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_ECHIDNA_NDIS_CLIENT_HOURS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')