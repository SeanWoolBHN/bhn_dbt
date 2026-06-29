SELECT
    INTERNALID                          AS INTERNAL_ID,

    {{ format_name('SURNAME') }}        AS LAST_NAME,
    {{ format_name('FIRSTNAME') }}      AS FIRST_NAME,
    {{ format_name('MIDDLENAME') }}     AS MIDDLE_NAME,
    {{ format_name('PREFERREDNAME') }}  AS PREF_NAME,
    {{ format_name('TITLE') }}          AS TITLE,

    {{ format_name('ADDRESS1') }}       AS ADDRESS1,
    {{ format_name('ADDRESS2') }}       AS ADDRESS2,
    {{ format_name('CITY') }}           AS CITY,
    TRIM(POSTCODE)                      AS POSTCODE,
    TRIM(FULLADDRESS)                   AS FULL_ADDRESS,

    {{ format_date('DOB') }}            AS DOB,
    AGE,
    UPPER(TRIM(SEX))                    AS GENDER,

    TRIM(MEDICARENO)                    AS MEDICARE_NO,
    TRIM(MEDICARELINENO)                AS MEDICARE_IRN,
    {{ format_date('MEDICAREEXPIRY') }} AS MEDICARE_EXPIRY_DATE,
    TRIM(RECORDNO)                      AS RECORD_NO,
    TRIM(PENSIONNO)                     AS PENSION_NO,
    TRIM(DVANO)                         AS DVA_NO,

    {{ format_phone('HOMEPHONE') }}     AS HOME_PHONE,
    {{ format_phone('WORKPHONE') }}     AS WORK_PHONE,
    {{ format_phone('MOBILEPHONE') }}   AS MOBILE_PHONE,

    LOWER(TRIM(EMAIL))                  AS EMAIL,

    _AIRBYTE_EXTRACTED_AT                   AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_BEST_PRACTICE_BPS_SEARCH_RESULT') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')