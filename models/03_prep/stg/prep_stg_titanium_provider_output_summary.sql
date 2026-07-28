SELECT
    TRIM(COC)                                      AS COC,
    TRY_TO_NUMBER(TRIM(AMOUNT),18,6)               AS AMOUNT,
    TRY_TO_NUMBER(TRIM(VISITS),18,6)               AS NO_OF_VISITS,
    TRY_TO_NUMBER(TRIM(FTAAPPT),18,6)              AS NO_OF_FTA_APPT,
    TRY_TO_NUMBER(TRIM(PATIENTS),18,6)             AS NO_OF_PATIENTS,
    {{ format_name('PROVIDER') }}                  AS PROVIDER_CODE,
    TRIM(TEXTBOX62)                                AS FTA_PCT,
    TRY_TO_NUMBER(TRIM(TOTALAPPT),18,6)            AS TOTAL_APPT,
    TRIM(APPTNOTREAT)                              AS APPT_NOT_TREAT,
    {{ format_name('PROVIDERNAME') }}              AS PROVIDER_NAME,
    TRIM(PROVIDERTYPE)                             AS PROVIDER_TYPE,
    TRIM(FTALENGTHHOURS)                           AS FTA_DURATION_HOURS,
    TRIM(PROVIDERREGTYPE)                          AS PROVIDER_REG_TYPE,
    TRY_TO_NUMBER(TRIM(APPTLENGTHHOURS1),18, 6)    AS APPT_DURATION_HOURS,

    _AIRBYTE_EXTRACTED_AT                           AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TITANIUM_PROVIDER_OUTPUT_SUMMARY') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')