SELECT
    UPPER(TRIM(STATUS))                          AS STATUS,
    {{ format_date('ISSUE_DATE') }}              AS ISSUE_DATE,
    {{ format_date('EXPIRY_DATE') }}             AS EXPIRY_DATE,
    {{ format_name('ISSUING_BODY') }}            AS ISSUING_BODY,
    TRIM(LICENSE_TYPE)                           AS LICENSE_TYPE,
    TRIM(EMPLOYEE_NUMBER)                        AS EMPLOYEE_NO,
    TRIM(IDENTIFICATION_NUMBER)                  AS LICENSE_ID,
    TRIM(LICENSE_CLASSIFICATION)                 AS LICENSE_CLASSIFICATION,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_CONNX_LICENCE_REGISTRATION') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')