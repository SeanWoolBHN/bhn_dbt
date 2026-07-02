SELECT
    CTOCC_ROWID                                   AS ROW_ID,
    TRIM(CTOCC_CODE)                              AS CODE,
    TRIM(CTOCC_DESC)                              AS DESC,
    CTOCC_DATEFROM                                AS DATE_FROM,
    TRIM(CTOCC_DATETO)                            AS DATE_TO,
    TRIM(CTOCC_OWNER)                             AS OWNER,
    TRIM(CTOCC_CODETABLETAGS)                     AS CODE_TABLE_TAGS,
    TRIM(CTOCC_CREATEDDATE)                       AS CREATED_DATE,
    TRIM(CTOCC_CREATEDTIME)                       AS CREATED_TIME,
    TRIM(CTOCC_CREATEDUSER_DR)                    AS CREATED_USER_DR,
    TRIM(CTOCC_UPDATEDDATE)                       AS UPDATED_DATE,
    TRIM(CTOCC_UPDATEDTIME)                       AS UPDATED_TIME,
    TRIM(CTOCC_UPDATEDUSER_DR)                    AS UPDATED_USER_DR,
    TRIM(CTOCC_CODETRANSLATED)                    AS CODE_TRANSLATED,
    TRIM(CTOCC_DESCTRANSLATED)                    AS DESC_TRANSLATED,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_CT_OCCUPATION') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')