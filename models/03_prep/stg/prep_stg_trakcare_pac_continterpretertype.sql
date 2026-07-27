SELECT
    INTERP_ROWID                                          AS ROW_ID,
    NULLIF(TRIM(INTERP_CODE), 'NULL')                     AS CODE,
    NULLIF(TRIM(INTERP_DESC), 'NULL')                     AS DESCRIPTION,
    NULLIF(TRIM(INTERP_OWNER), 'NULL')                    AS OWNER,
    INTERP_DATETO                                         AS DATE_TO,
    INTERP_DATEFROM                                       AS DATE_FROM,
    INTERP_CREATEDDATE                                    AS CREATED_DATE,
    INTERP_CREATEDTIME                                    AS CREATED_TIME,
    INTERP_UPDATEDDATE                                    AS UPDATED_DATE,
    INTERP_UPDATEDTIME                                    AS UPDATED_TIME,
    NULLIF(TRIM(INTERP_CODETABLETAGS), 'NULL')            AS CODE_TABLE_TAGS,
    INTERP_CREATEDUSER_DR                                 AS CREATED_USER_DR,
    INTERP_UPDATEDUSER_DR                                 AS UPDATED_USER_DR,
    _AIRBYTE_EXTRACTED_AT                                 AS AIRBYTE_EXTRACTED_TS
FROM {{ ref('HIST_TRAKCARE_PAC_CONTINTERPRETERTYPE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')