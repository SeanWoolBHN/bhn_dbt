SELECT
    CONTMETH_ROWID                                        AS ROW_ID,
    NULLIF(TRIM(CONTMETH_CODE), 'NULL')                   AS CODE,
    NULLIF(TRIM(CONTMETH_DESC), 'NULL')                   AS DESCRIPTION,
    NULLIF(TRIM(CONTMETH_OWNER), 'NULL')                  AS OWNER,
    CONTMETH_DATETO                                       AS DATE_TO,
    CONTMETH_DATEFROM                                     AS DATE_FROM,
    CONTMETH_CREATEDDATE                                  AS CREATED_DATE,
    CONTMETH_CREATEDTIME                                  AS CREATED_TIME,
    CONTMETH_UPDATEDDATE                                  AS UPDATED_DATE,
    CONTMETH_UPDATEDTIME                                  AS UPDATED_TIME,
    NULLIF(TRIM(CONTMETH_CODETABLETAGS), 'NULL')          AS CODE_TABLE_TAGS,
    CONTMETH_CREATEDUSER_DR                               AS CREATED_USER_DR,
    CONTMETH_UPDATEDUSER_DR                               AS UPDATED_USER_DR,
    _AIRBYTE_EXTRACTED_AT                                 AS AIRBYTE_EXTRACTED_TS
FROM {{ ref('HIST_TRAKCARE_PAC_CONTMETHOD') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')