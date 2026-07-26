SELECT
    LOCGOAL_ROWID                                         AS ROW_ID,
    NULLIF(TRIM(LOCGOAL_CODE), 'NULL')                    AS CODE,
    NULLIF(TRIM(LOCGOAL_DESC), 'NULL')                    AS DESCRIPTION,
    NULLIF(TRIM(LOCGOAL_OWNER), 'NULL')                   AS OWNER,
    LOCGOAL_DATETO                                        AS DATE_TO,
    LOCGOAL_DATEFROM                                      AS DATE_FROM,
    LOCGOAL_CREATEDDATE                                   AS CREATED_DATE,
    LOCGOAL_CREATEDTIME                                   AS CREATED_TIME,
    LOCGOAL_UPDATEDDATE                                   AS UPDATED_DATE,
    LOCGOAL_UPDATEDTIME                                   AS UPDATED_TIME,
    NULLIF(TRIM(LOCGOAL_CODETABLETAGS), 'NULL')           AS CODE_TABLE_TAGS,
    LOCGOAL_CREATEDUSER_DR                                AS CREATED_USER_DR,
    LOCGOAL_UPDATEDUSER_DR                                AS UPDATED_USER_DR,
    _AIRBYTE_EXTRACTED_AT                                 AS AIRBYTE_EXTRACTED_TS
FROM {{ ref('HIST_TRAKCARE_PAC_CONTLOCALGOAL') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')