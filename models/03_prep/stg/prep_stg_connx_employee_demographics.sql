SELECT
    {{ format_date('DOB') }}                     AS DOB,
    UPPER(TRIM(GENDER))                          AS GENDER,
    TRIM(POSTCODE)                                AS POSTCODE,
    {{ format_name('DEPARTMENT') }}              AS DEPARTMENT,
    {{ format_name('NATIONALITY') }}             AS NATIONALITY,
    TRIM(LANGUAGES_SPOKEN)                        AS LANGUAGES_SPOKEN,
    TRIM("ETHNICITY_AU/NZ_")                      AS ETHNICITY,

    _AIRBYTE_EXTRACTED_AT                          AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_CONNX_EMPLOYEE_DEMOGRAPHICS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')