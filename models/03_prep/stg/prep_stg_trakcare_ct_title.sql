SELECT
    TTL_ROWID                                     AS ROW_ID,
    TRIM(TTL_CODE)                                AS CODE,
    TRIM(TTL_DESC)                                AS DESC,
    TTL_DATEFROM                                  AS DATE_FROM,
    CAST(TRIM(TTL_DATETO) AS DATE)                AS DATE_TO,
    TRIM(TTL_OWNER)                               AS OWNER,
    TRIM(TTL_CODETABLETAGS)                       AS CODE_TABLE_TAGS,
    CAST(TRIM(TTL_CREATEDDATE) AS DATE)           AS CREATED_DATE,
    CAST(TRIM(TTL_CREATEDTIME) AS TIME)           AS CREATED_TIME,
    TRY_TO_NUMBER(TRIM(TTL_CREATEDUSER_DR),18,6)  AS CREATED_USER_DR,
    TRIM(TTL_UPDATEDDATE)                         AS UPDATED_DATE,
    TRIM(TTL_UPDATEDTIME)                         AS UPDATED_TIME,
    TRY_TO_NUMBER(TRIM(TTL_UPDATEDUSER_DR),18,6)  AS UPDATED_USER_DR,
    TRIM(TTL_CODETRANSLATED)                      AS CODE_TRANSLATED,
    TRIM(TTL_DESCTRANSLATED)                      AS DESC_TRANSLATED,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_CT_TITLE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')