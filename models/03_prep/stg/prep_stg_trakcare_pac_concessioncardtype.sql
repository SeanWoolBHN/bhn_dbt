SELECT
    CONCCARD_ROWID                                                        AS ROW_ID,
    CONCCARD_CODE                                                         AS CODE,
    NULLIF(TRIM(CONCCARD_DESC), 'NULL')                                   AS DESCRIPTION,
    CONCCARD_DATEFROM                                                     AS DATE_FROM,
    NULLIF(TRIM(CONCCARD_DATETO), 'NULL')                                 AS DATE_TO,
    NULLIF(TRIM(CONCCARD_OWNER), 'NULL')                                  AS OWNER,
    NULLIF(TRIM(CONCCARD_CODETABLETAGS), 'NULL')                          AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(CONCCARD_CREATEDDATE), 'NULL'))               AS CREATED_DATE,
    NULLIF(TRIM(CONCCARD_CREATEDTIME), 'NULL')                            AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(CONCCARD_CREATEDUSER_DR), 'NULL'), 18, 6)   AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(CONCCARD_UPDATEDDATE), 'NULL'))               AS UPDATED_DATE,
    NULLIF(TRIM(CONCCARD_UPDATEDTIME), 'NULL')                            AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(CONCCARD_UPDATEDUSER_DR), 'NULL'), 18, 6)   AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                                                 AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_CONCESSIONCARDTYPE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')