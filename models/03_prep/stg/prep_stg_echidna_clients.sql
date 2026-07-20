SELECT
    LOWER(TRIM(EMAIL))                                                      AS EMAIL,
    UPPER(TRIM(STATE))                                                      AS STATE,
    UPPER(TRIM(GENDER))                                                     AS GENDER,
    {{ format_name('SUBURB') }}                                             AS CITY,
    {{ format_name('ADDRESS') }}                                            AS ADDRESS_1,
    TRIM(SUBURNE)                                                           AS CITY_2,
    {{ format_phone('PHONE_NO') }}                                          AS PHONE_NO,
    CAST(TRIM(POSTCODE) AS TEXT)                                            AS POSTCODE,
    TRIM(AGE_YEARS)                                                         AS AGE_YEARS,
    TRIM(AGE_MONTHS)                                                        AS AGE_MONTHS,
    {{ format_phone('PHONE_NUMBER') }}                                      AS PHONE_NO_2,
    CAST(DOB_ESTIMATED AS BOOLEAN)                                          AS IS_DOB_ESTIMATED,
    {{ format_date('DATE_OF_BIRTH') }}                                      AS DOB,
    {{ format_name('CLIENT_SURNAME') }}                                     AS LAST_NAME,
    {{ format_name('CONTACT_SURNAME') }}                                    AS CONTACT_LAST_NAME,
    {{ format_date('DATE_OF_REFERRAL') }}                                   AS REFERRAL_DATE,
    {{ format_name('CLIENT_FIRST_NAME') }}                                  AS FIRST_NAME,
    TRIM(PRIMARY_DIAGNOSIS)                                                 AS PRIMARY_DIAGNOSIS,
    {{ format_name('CLIENT_MIDDLE_NAME') }}                                 AS MIDDLE_NAME,
    {{ format_name('CONTACT_FIRST_NAME') }}                                 AS CONTACT_FIRST_NAME,
    TRIM(RELATIONSHIP_TO_CLIENT)                                            AS RELATIONSHIP_TO_CLIENT,
    -- Actually NDIS number, ensure it can be int'ed
    TRY_TO_NUMBER(REPLACE(TRIM(MAIN_LANGUAGE_SPOKEN_AT_HOME),' ',''),38,0)  AS NDIS_NO,

    _AIRBYTE_EXTRACTED_AT                          AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_ECHIDNA_CLIENTS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')