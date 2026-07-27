SELECT
    CARAVL_ROWID                                                          AS ROW_ID,
    NULLIF(TRIM(CARAVL_CODE), 'NULL')                                     AS CODE,
    NULLIF(TRIM(CARAVL_DESC), 'NULL')                                     AS DESCRIPTION,
    CARAVL_DATEFROM                                                       AS DATE_FROM,
    NULLIF(TRIM(CARAVL_DATETO), 'NULL')                                   AS DATE_TO,
    NULLIF(TRIM(CARAVL_DEFAULT), 'NULL')                                  AS DEFAULT,
    NULLIF(TRIM(CARAVL_NATIONALCODE), 'NULL')                             AS NATIONAL_CODE,
    NULLIF(TRIM(CARAVL_DISCHARGETYPE), 'NULL')                            AS DISCHARGE_TYPE,
    NULLIF(TRIM(CARAVL_CARETYP), 'NULL')                                  AS CARE_TYPE,
    NULLIF(TRIM(CARAVL_OWNER), 'NULL')                                    AS OWNER,
    NULLIF(TRIM(CARAVL_CODETABLETAGS), 'NULL')                            AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(CARAVL_CREATEDDATE), 'NULL'))                 AS CREATED_DATE,
    NULLIF(TRIM(CARAVL_CREATEDTIME), 'NULL')                              AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(CARAVL_CREATEDUSER_DR), 'NULL'), 18, 6)     AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(CARAVL_UPDATEDDATE), 'NULL'))                 AS UPDATED_DATE,
    NULLIF(TRIM(CARAVL_UPDATEDTIME), 'NULL')                              AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(CARAVL_UPDATEDUSER_DR), 'NULL'), 18, 6)     AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                                                 AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_CARERAVAILABILITY') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')