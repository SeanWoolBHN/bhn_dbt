SELECT
    TRIM(COC)                                     AS COC,
    TRIM(AMOUNT)                                   AS AMOUNT,
    TRIM(VISITS)                                   AS NO_OF_VISITS,
    TRIM(FTAAPPT)                                  AS NO_OF_FTA_APPT,
    TRIM(PATIENTS)                                 AS NO_OF_PATIENTS,
    {{ format_name('PROVIDER') }}                  AS PROVIDER_CODE,
    TRIM(TEXTBOX62)                                AS TEXTBOX62,
    TRIM(TOTALAPPT)                                AS TOTAL_APPT,
    TRIM(APPTNOTREAT)                              AS APPT_NOT_TREAT,
    {{ format_name('PROVIDERNAME') }}              AS PROVIDER_NAME,
    TRIM(PROVIDERTYPE)                             AS PROVIDER_TYPE,
    TRIM(FTALENGTHHOURS)                           AS FTA_DURATION_HOURS,
    TRIM(PROVIDERREGTYPE)                          AS PROVIDER_REG_TYPE,
    TRIM(APPTLENGTHHOURS1)                         AS APPT_DURATION_HOURS,

    _AIRBYTE_EXTRACTED_AT                           AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TITANIUM_PROVIDER_OUTPUT_SUMMARY') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')