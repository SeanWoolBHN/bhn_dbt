SELECT
    DSCL_ROWID                                            AS ROW_ID,
    NULLIF(TRIM(DSCL_CODE), 'NULL')                       AS CODE,
    NULLIF(TRIM(DSCL_DESC), 'NULL')                       AS DESCRIPTION,
    NULLIF(TRIM(DSCL_OWNER), 'NULL')                      AS OWNER,
    DSCL_DATETO                                           AS DATE_TO,
    NULLIF(TRIM(DSCL_DEFAULT), 'NULL')                    AS DEFAULT_FLAG,
    DSCL_DATEFROM                                         AS DATE_FROM,
    NULLIF(TRIM(DSCL_DECEASED), 'NULL')                   AS DECEASED,
    NULLIF(TRIM(DSCL_ICONNAME), 'NULL')                   AS ICON_NAME,
    DSCL_CREATEDDATE                                      AS CREATED_DATE,
    DSCL_CREATEDTIME                                      AS CREATED_TIME,
    DSCL_UPDATEDDATE                                      AS UPDATED_DATE,
    DSCL_UPDATEDTIME                                      AS UPDATED_TIME,
    NULLIF(TRIM(DSCL_WAITINGTYPE), 'NULL')                AS WAITING_TYPE,
    NULLIF(TRIM(DSCL_ICONPRIORITY), 'NULL')               AS ICON_PRIORITY,
    NULLIF(TRIM(DSCL_NATIONALCODE), 'NULL')               AS NATIONAL_CODE,
    NULLIF(TRIM(DSCL_CODETABLETAGS), 'NULL')              AS CODE_TABLE_TAGS,
    DSCL_CREATEDUSER_DR                                   AS CREATED_USER_DR,
    DSCL_UPDATEDUSER_DR                                   AS UPDATED_USER_DR,
    _AIRBYTE_EXTRACTED_AT                                 AS AIRBYTE_EXTRACTED_TS
FROM {{ ref('HIST_TRAKCARE_PAC_DISCHCLASSIFICATION') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')