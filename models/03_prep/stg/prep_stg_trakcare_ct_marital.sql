SELECT
    CTMAR_ROWID                                   AS ROW_ID,
    TRIM(CTMAR_CODE)                              AS CODE,
    TRIM(CTMAR_DESC)                              AS DESC,
    TRIM(CTMAR_PRS2)                              AS PRS2,
    CTMAR_DATEFROM                                AS DATE_FROM,
    TRIM(CTMAR_DATETO)                            AS DATE_TO,
    TRIM(CTMAR_OWNER)                             AS OWNER,
    TRIM(CTMAR_CODETABLETAGS)                     AS CODE_TABLE_TAGS,
    TRIM(CTMAR_CREATEDDATE)                       AS CREATED_DATE,
    TRIM(CTMAR_CREATEDTIME)                       AS CREATED_TIME,
    TRIM(CTMAR_CREATEDUSER_DR)                    AS CREATED_USER_DR,
    TRIM(CTMAR_UPDATEDDATE)                       AS UPDATED_DATE,
    TRIM(CTMAR_UPDATEDTIME)                       AS UPDATED_TIME,
    TRIM(CTMAR_UPDATEDUSER_DR)                    AS UPDATED_USER_DR,
    TRIM(CTMAR_CODETRANSLATED)                    AS CODE_TRANSLATED,
    TRIM(CTMAR_DESCTRANSLATED)                    AS DESC_TRANSLATED,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_CT_MARITAL') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')