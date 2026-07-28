SELECT
    REQTYP_ROWID                                          AS ROW_ID,
    NULLIF(TRIM(REQTYP_CODE), 'NULL')                     AS CODE,
    NULLIF(TRIM(REQTYP_DESC), 'NULL')                     AS DESCRIPTION,
    NULLIF(TRIM(REQTYP_OWNER), 'NULL')                    AS OWNER,
    REQTYP_DATETO                                         AS DATE_TO,
    REQTYP_DATEFROM                                       AS DATE_FROM,
    REQTYP_CREATEDDATE                                    AS CREATED_DATE,
    REQTYP_CREATEDTIME                                    AS CREATED_TIME,
    REQTYP_UPDATEDDATE                                    AS UPDATED_DATE,
    REQTYP_UPDATEDTIME                                    AS UPDATED_TIME,
    NULLIF(TRIM(REQTYP_CODETABLETAGS), 'NULL')            AS CODE_TABLE_TAGS,
    REQTYP_CREATEDUSER_DR                                 AS CREATED_USER_DR,
    REQTYP_UPDATEDUSER_DR                                 AS UPDATED_USER_DR,
    _AIRBYTE_EXTRACTED_AT                                 AS AIRBYTE_EXTRACTED_TS
FROM {{ ref('HIST_TRAKCARE_PAC_REQUESTTYPE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')