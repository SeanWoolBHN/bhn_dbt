SELECT
    TRIM("TO")                                   AS "TO",
    {{ format_date('"DATE"') }}                  AS "DATE",
    TRIM("FROM")                                 AS "FROM",
    TRIM(RATE)                                   AS RATE,
    TRIM(HOURS)                                  AS HOURS,
    TRIM(VALUE)                                  AS VALUE,
    TRIM(HOURS2)                                 AS HOURS2,
    {{ format_name('REGION') }}                  AS REGION,
    TRIM(FUNDING)                                AS FUNDING,
    TRIM(ITEM_NO)                                AS ITEM_NO,
    TRIM(NDIS_NO)                                AS NDIS_NO,
    TRIM(ACTIVITY)                               AS ACTIVITY,
    TRIM(CLIENT_ID)                              AS ECHIDNA_CLIENT_ID,
    {{ format_name('CONSULTANT') }}              AS CONSULTANT_FULL_NAME,
    TRIM(INVOICE_NO)                             AS INVOICE_NO,
    TRIM(STAFF_TYPE)                             AS STAFF_TYPE,
    TRIM(AMOUNT_PAID)                            AS AMOUNT_PAID,
    {{ format_name('CLIENT_NAME') }}             AS FIRST_NAME,
    TRIM(HOURS_SPENT)                            AS HOURS_SPENT,
    TRIM(CONSULTANT_ID)                          AS CONSULTANT_ID,
    TRIM(NDIS_CLAIM_NO)                          AS NDIS_CLAIM_NO,
    {{ format_name('CLIENT_SURNAME') }}          AS LAST_NAME,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_ECHIDNA_NDIS_CLIENT_HOURS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')