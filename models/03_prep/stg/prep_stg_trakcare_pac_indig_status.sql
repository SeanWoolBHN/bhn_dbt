SELECT
    INDST_ROWID                                                            AS ROW_ID,
    INDST_CODE                                                             AS CODE,
    NULLIF(TRIM(INDST_DESC), 'NULL')                                       AS DESCRIPTION,
    INDST_DATEFROM                                                         AS DATE_FROM,
    NULLIF(TRIM(INDST_DATETO), 'NULL')                                     AS DATE_TO,
    NULLIF(TRIM(INDST_NATIONALCODE), 'NULL')                               AS NATIONAL_CODE,
    NULLIF(TRIM(INDST_OWNER), 'NULL')                                      AS OWNER,
    NULLIF(TRIM(INDST_CODETABLETAGS), 'NULL')                              AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(INDST_CREATEDDATE), 'NULL'))                   AS CREATED_DATE,
    NULLIF(TRIM(INDST_CREATEDTIME), 'NULL')                                AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(INDST_CREATEDUSER_DR), 'NULL'), 18, 6)       AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(INDST_UPDATEDDATE), 'NULL'))                   AS UPDATED_DATE,
    NULLIF(TRIM(INDST_UPDATEDTIME), 'NULL')                                AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(INDST_UPDATEDUSER_DR), 'NULL'), 18, 6)       AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                                                  AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_INDIGSTATUS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')