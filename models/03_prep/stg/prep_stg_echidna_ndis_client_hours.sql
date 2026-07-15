SELECT
    TRIM("TO")                                      AS APPT_END_TIME,
    {{ format_date('"DATE"') }}                     AS APPT_DATE,
    TRIM("FROM")                                    AS APPT_START_TIME,
    TRY_TO_NUMERIC(TRIM(RATE),18,6)                 AS RATE,
    TRY_TO_NUMERIC(TRIM(HOURS),18,6)                AS HOURS,
    TRY_TO_NUMERIC(TRIM(VALUE),18,6)                AS VALUE,
    TRY_TO_NUMERIC(TRIM(HOURS2),18,6)               AS HOURS_2,
    {{ format_name('REGION') }}                     AS REGION,
    TRIM(FUNDING)                                   AS FUNDING,
    TRIM(ITEM_NO)                                   AS ITEM_NO,
    TRY_TO_NUMBER(TRIM(NDIS_NO),38)                 AS NDIS_NO,
    TRIM(ACTIVITY)                                  AS ACTIVITY,
    TRIM(CLIENT_ID)                                 AS ECHIDNA_CLIENT_ID,
    {{ format_name('CONSULTANT') }}                 AS CONSULTANT_FULL_NAME,
    TRY_TO_NUMBER(TRIM(INVOICE_NO),38)              AS INVOICE_NO,
    TRIM(STAFF_TYPE)                                AS STAFF_TYPE,
    TRY_TO_NUMBER(TRIM(AMOUNT_PAID),18,6)           AS AMOUNT_PAID,
    {{ format_name('CLIENT_NAME') }}                AS FIRST_NAME,
    TRY_TO_NUMERIC(TRIM(HOURS_SPENT),18,6)          AS HOURS_SPENT,
    TRY_TO_NUMBER(TRIM(CONSULTANT_ID),38)           AS CONSULTANT_ID,
    TRY_TO_NUMBER(TRIM(NDIS_CLAIM_NO),38)           AS NDIS_CLAIM_NO,
    {{ format_name('CLIENT_SURNAME') }}             AS LAST_NAME,

    _AIRBYTE_EXTRACTED_AT                           AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_ECHIDNA_NDIS_CLIENT_HOURS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')