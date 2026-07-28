SELECT
    RST_ROWID                                             AS ROW_ID,
    NULLIF(TRIM(RST_CODE), 'NULL')                        AS CODE,
    NULLIF(TRIM(RST_DESC), 'NULL')                        AS DESCRIPTION,
    NULLIF(TRIM(RST_OWNER), 'NULL')                       AS OWNER,
    RST_DATETO                                            AS DATE_TO,
    RST_DATEFROM                                          AS DATE_FROM,
    NULLIF(TRIM(RST_ICANNAME), 'NULL')                    AS ICAN_NAME,
    RST_CREATEDDATE                                       AS CREATED_DATE,
    RST_CREATEDTIME                                       AS CREATED_TIME,
    RST_UPDATEDDATE                                       AS UPDATED_DATE,
    RST_UPDATEDTIME                                       AS UPDATED_TIME,
    NULLIF(TRIM(RST_VISITSTATUS), 'NULL')                 AS VISIT_STATUS,
    RST_ICONPRIORITY                                      AS ICON_PRIORITY,
    NULLIF(TRIM(RST_NATIONALCODE), 'NULL')                AS NATIONAL_CODE,
    NULLIF(TRIM(RST_CODETABLETAGS), 'NULL')               AS CODE_TABLE_TAGS,
    RST_CREATEDUSER_DR                                    AS CREATED_USER_DR,
    RST_UPDATEDUSER_DR                                    AS UPDATED_USER_DR,
    _AIRBYTE_EXTRACTED_AT                                 AS AIRBYTE_EXTRACTED_TS
FROM {{ ref('HIST_TRAKCARE_PAC_REFERRALSTATUS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')