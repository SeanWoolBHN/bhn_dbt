SELECT
    TTL_ROWID                                     AS ROW_ID,
    TRIM(TTL_CODE)                                AS CODE,
    TRIM(TTL_DESC)                                AS DESC,
    TTL_DATEFROM                                  AS DATE_FROM,
    TRIM(TTL_DATETO)                              AS DATE_TO,
    TRIM(TTL_OWNER)                               AS OWNER,
    TRIM(TTL_CODETABLETAGS)                       AS CODE_TABLE_TAGS,
    TRIM(TTL_CREATEDDATE)                         AS CREATED_DATE,
    TRIM(TTL_CREATEDTIME)                         AS CREATED_TIME,
    TRIM(TTL_CREATEDUSER_DR)                      AS CREATED_USER_DR,
    TRIM(TTL_UPDATEDDATE)                         AS UPDATED_DATE,
    TRIM(TTL_UPDATEDTIME)                         AS UPDATED_TIME,
    TRIM(TTL_UPDATEDUSER_DR)                      AS UPDATED_USER_DR,
    TRIM(TTL_CODETRANSLATED)                      AS CODE_TRANSLATED,
    TRIM(TTL_DESCTRANSLATED)                      AS DESC_TRANSLATED,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_CT_TITLE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')