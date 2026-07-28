SELECT
    CONTOUTC_ROWID                                        AS ROW_ID,
    NULLIF(TRIM(CONTOUTC_CODE), 'NULL')                   AS CODE,
    NULLIF(TRIM(CONTOUTC_DESC), 'NULL')                   AS DESCRIPTION,
    NULLIF(TRIM(CONTOUTC_OWNER), 'NULL')                  AS OWNER,
    CONTOUTC_DATETO                                       AS DATE_TO,
    CONTOUTC_DATEFROM                                     AS DATE_FROM,
    CONTOUTC_CREATEDDATE                                  AS CREATED_DATE,
    CONTOUTC_CREATEDTIME                                  AS CREATED_TIME,
    CONTOUTC_UPDATEDDATE                                  AS UPDATED_DATE,
    CONTOUTC_UPDATEDTIME                                  AS UPDATED_TIME,
    NULLIF(TRIM(CONTOUTC_CODETABLETAGS), 'NULL')          AS CODE_TABLE_TAGS,
    CONTOUTC_CREATEDUSER_DR                               AS CREATED_USER_DR,
    CONTOUTC_UPDATEDUSER_DR                               AS UPDATED_USER_DR,
    _AIRBYTE_EXTRACTED_AT                                 AS AIRBYTE_EXTRACTED_TS
FROM {{ ref('HIST_TRAKCARE_PAC_CONTOUTCOME') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')