SELECT
    CTRLG_ROWID                                   AS ROW_ID,
    TRIM(CTRLG_CODE)                              AS CODE,
    TRIM(CTRLG_DESC)                              AS DESC,
    CTRLG_DATEFROM                                AS DATE_FROM,
    TRIM(CTRLG_DATETO)                            AS DATE_TO,
    TRIM(CTRLG_OWNER)                             AS OWNER,
    TRIM(CTRLG_CODETABLETAGS)                     AS CODE_TABLE_TAGS,
    TRIM(CTRLG_CREATEDDATE)                       AS CREATED_DATE,
    TRIM(CTRLG_CREATEDTIME)                       AS CREATED_TIME,
    TRIM(CTRLG_CREATEDUSER_DR)                    AS CREATED_USER_DR,
    TRIM(CTRLG_UPDATEDDATE)                       AS UPDATED_DATE,
    TRIM(CTRLG_UPDATEDTIME)                       AS UPDATED_TIME,
    TRIM(CTRLG_UPDATEDUSER_DR)                    AS UPDATED_USER_DR,
    TRIM(CTRLG_CODETRANSLATED)                    AS CODE_TRANSLATED,
    TRIM(CTRLG_DESCTRANSLATED)                    AS DESC_TRANSLATED,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_CT_RELIGION') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')