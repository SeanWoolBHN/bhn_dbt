SELECT
    CONTDELMODE_ROWID                                     AS ROW_ID,
    NULLIF(TRIM(CONTDELMODE_CODE), 'NULL')                AS CODE,
    NULLIF(TRIM(CONTDELMODE_DESC), 'NULL')                AS DESCRIPTION,
    NULLIF(TRIM(CONTDELMODE_OWNER), 'NULL')               AS OWNER,
    CONTDELMODE_DATETO                                    AS DATE_TO,
    CONTDELMODE_DATEFROM                                  AS DATE_FROM,
    CONTDELMODE_CREATEDDATE                               AS CREATED_DATE,
    CONTDELMODE_CREATEDTIME                               AS CREATED_TIME,
    CONTDELMODE_UPDATEDDATE                               AS UPDATED_DATE,
    CONTDELMODE_UPDATEDTIME                               AS UPDATED_TIME,
    NULLIF(TRIM(CONTDELMODE_CODETABLETAGS), 'NULL')       AS CODE_TABLE_TAGS,
    CONTDELMODE_CREATEDUSER_DR                            AS CREATED_USER_DR,
    CONTDELMODE_UPDATEDUSER_DR                            AS UPDATED_USER_DR,
    _AIRBYTE_EXTRACTED_AT                                 AS AIRBYTE_EXTRACTED_TS
FROM {{ ref('HIST_TRAKCARE_PAC_CONTDELIVMODE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')