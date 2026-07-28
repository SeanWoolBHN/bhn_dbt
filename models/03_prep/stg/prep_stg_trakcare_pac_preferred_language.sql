SELECT
    PREFL_ROWID                                                            AS ROW_ID,
    NULLIF(TRIM(PREFL_CODE), 'NULL')                                       AS CODE,
    NULLIF(TRIM(PREFL_DESC), 'NULL')                                       AS DESCRIPTION,
    NULLIF(TRIM(PREFL_VEMDCODE), 'NULL')                                   AS VEMD_CODE,
    PREFL_DATEFROM                                                         AS DATE_FROM,
    NULLIF(TRIM(PREFL_DATETO), 'NULL')                                     AS DATE_TO,
    NULLIF(TRIM(PREFL_OWNER), 'NULL')                                      AS OWNER,
    NULLIF(TRIM(PREFL_CODETABLETAGS), 'NULL')                              AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(PREFL_CREATEDDATE), 'NULL'))                   AS CREATED_DATE,
    NULLIF(TRIM(PREFL_CREATEDTIME), 'NULL')                                AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(PREFL_CREATEDUSER_DR), 'NULL'), 18, 6)       AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(PREFL_UPDATEDDATE), 'NULL'))                   AS UPDATED_DATE,
    NULLIF(TRIM(PREFL_UPDATEDTIME), 'NULL')                                AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(PREFL_UPDATEDUSER_DR), 'NULL'), 18, 6)       AS UPDATED_USER_DR,
    NULLIF(TRIM(PREFL_DIALECT), 'NULL')                                    AS DIALECT,
    NULLIF(TRIM(PREFL_CODETRANSLATED), 'NULL')                             AS CODE_TRANSLATED,
    NULLIF(TRIM(PREFL_DESCTRANSLATED), 'NULL')                             AS DESC_TRANSLATED,

    _AIRBYTE_EXTRACTED_AT                                                  AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_PREFERREDLANGUAGE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')