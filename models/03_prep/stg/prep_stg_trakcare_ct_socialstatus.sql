SELECT
    SS_ROWID                                                              AS ROW_ID,
    SS_CODE                                                               AS CODE,
    NULLIF(TRIM(SS_DESC), 'NULL')                                         AS DESCRIPTION,
    NULLIF(TRIM(SS_OWNER), 'NULL')                                        AS OWNER,
    NULLIF(TRIM(SS_CODETABLETAGS), 'NULL')                                AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(SS_CREATEDDATE), 'NULL'))                     AS CREATED_DATE,
    NULLIF(TRIM(SS_CREATEDTIME), 'NULL')                                  AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(SS_CREATEDUSER_DR), 'NULL'), 18, 6)         AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(SS_UPDATEDDATE), 'NULL'))                     AS UPDATED_DATE,
    NULLIF(TRIM(SS_UPDATEDTIME), 'NULL')                                  AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(SS_UPDATEDUSER_DR), 'NULL'), 18, 6)         AS UPDATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(SS_DATEFROM), 'NULL'))                        AS DATE_FROM,
    TRY_TO_DATE(NULLIF(TRIM(SS_DATETO), 'NULL'))                          AS DATE_TO,
    TRY_TO_NUMBER(NULLIF(TRIM(SS_SEX_DR), 'NULL'), 18, 6)                 AS SEX_DR,

    _AIRBYTE_EXTRACTED_AT                                                 AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_CT_SOCIALSTATUS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')