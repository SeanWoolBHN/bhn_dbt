SELECT
    PRESISS_ROWID                                         AS ROW_ID,
    NULLIF(TRIM(PRESISS_CODE), 'NULL')                    AS CODE,
    NULLIF(TRIM(PRESISS_DESC), 'NULL')                    AS DESCRIPTION,
    NULLIF(TRIM(PRESISS_OWNER), 'NULL')                   AS OWNER,
    PRESISS_DATETO                                        AS DATE_TO,
    PRESISS_DATEFROM                                      AS DATE_FROM,
    PRESISS_CREATEDDATE                                   AS CREATED_DATE,
    PRESISS_CREATEDTIME                                   AS CREATED_TIME,
    PRESISS_UPDATEDDATE                                   AS UPDATED_DATE,
    PRESISS_UPDATEDTIME                                   AS UPDATED_TIME,
    NULLIF(TRIM(PRESISS_CODETABLETAGS), 'NULL')           AS CODE_TABLE_TAGS,
    PRESISS_CREATEDUSER_DR                                AS CREATED_USER_DR,
    PRESISS_UPDATEDUSER_DR                                AS UPDATED_USER_DR,
    _AIRBYTE_EXTRACTED_AT                                 AS AIRBYTE_EXTRACTED_TS
FROM {{ ref('HIST_TRAKCARE_PAC_CONTPRESENTINGISSUE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')