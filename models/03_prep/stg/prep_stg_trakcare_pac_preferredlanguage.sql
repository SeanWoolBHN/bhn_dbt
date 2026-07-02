SELECT
    PREFL_ROWID                                   AS ROW_ID,
    TRIM(PREFL_CODE)                              AS CODE,
    TRIM(PREFL_DESC)                              AS DESC,
    TRIM(PREFL_VEMDCODE)                          AS VEMD_CODE,
    PREFL_DATEFROM                                AS DATE_FROM,
    TRIM(PREFL_DATETO)                            AS DATE_TO,
    TRIM(PREFL_OWNER)                             AS OWNER,
    TRIM(PREFL_CODETABLETAGS)                     AS CODE_TABLE_TAGS,
    TRIM(PREFL_CREATEDDATE)                       AS CREATED_DATE,
    TRIM(PREFL_CREATEDTIME)                       AS CREATED_TIME,
    TRIM(PREFL_CREATEDUSER_DR)                    AS CREATED_USER_DR,
    TRIM(PREFL_UPDATEDDATE)                       AS UPDATED_DATE,
    TRIM(PREFL_UPDATEDTIME)                       AS UPDATED_TIME,
    TRIM(PREFL_UPDATEDUSER_DR)                    AS UPDATED_USER_DR,
    TRIM(PREFL_DIALECT)                           AS DIALECT,
    TRIM(PREFL_CODETRANSLATED)                    AS CODE_TRANSLATED,
    TRIM(PREFL_DESCTRANSLATED)                    AS DESC_TRANSLATED,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_PREFERREDLANGUAGE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')