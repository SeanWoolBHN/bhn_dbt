SELECT
    INTERNALID                          AS INTERNAL_ID,

    {{ format_name('SURNAME') }}        AS LAST_NAME,
    {{ format_name('FIRSTNAME') }}      AS FIRST_NAME,
    {{ format_name('MIDDLENAME') }}     AS MIDDLE_NAME,
    {{ format_name('PREFERREDNAME') }}  AS PREF_NAME,
    {{ format_name('TITLE') }}          AS TITLE,

    {{ format_name('ADDRESS1') }}       AS ADDRESS_1,
    {{ format_name('ADDRESS2') }}       AS ADDRESS_2,
    {{ format_name('CITY') }}           AS CITY,
    TRIM(POSTCODE)                      AS POSTCODE,
    TRIM(FULLADDRESS)                   AS FULL_ADDRESS,

    {{ format_date('DOB') }}            AS DOB,
    AGE,
    UPPER(TRIM(SEX))                    AS GENDER,

    TRY_TO_NUMBER(TRIM(MEDICARENO),18,6)    AS MEDICARE_NO,
    TRY_TO_NUMBER(TRIM(MEDICARELINENO),18,6)AS MEDICARE_IRN,
    {{ format_date('MEDICAREEXPIRY') }}     AS MEDICARE_EXPIRY_DATE,
    TRY_TO_NUMBER(TRIM(RECORDNO),18,6)      AS RECORD_NO,
    TRY_TO_NUMBER(TRIM(PENSIONNO),18,6)     AS PENSION_NO,
    TRY_TO_NUMBER(TRIM(DVANO),18,6)     AS DVA_NO,

    {{ format_phone('HOMEPHONE') }}     AS HOME_PHONE,
    {{ format_phone('WORKPHONE') }}     AS WORK_PHONE,
    {{ format_phone('MOBILEPHONE') }}   AS MOBILE_PHONE,

    LOWER(TRIM(EMAIL))                  AS EMAIL,

    _AIRBYTE_EXTRACTED_AT                   AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_BEST_PRACTICE_BPS_SEARCH_RESULT') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')