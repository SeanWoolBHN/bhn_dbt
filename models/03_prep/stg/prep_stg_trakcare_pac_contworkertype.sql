SELECT
    WORKT_ROWID                                           AS ROW_ID,
    NULLIF(TRIM(WORKT_CODE), 'NULL')                      AS CODE,
    NULLIF(TRIM(WORKT_DESC), 'NULL')                      AS DESCRIPTION,
    NULLIF(TRIM(WORKT_OWNER), 'NULL')                     AS OWNER,
    WORKT_DATETO                                          AS DATE_TO,
    WORKT_DATEFROM                                        AS DATE_FROM,
    WORKT_CREATEDDATE                                     AS CREATED_DATE,
    WORKT_CREATEDTIME                                     AS CREATED_TIME,
    WORKT_UPDATEDDATE                                     AS UPDATED_DATE,
    WORKT_UPDATEDTIME                                     AS UPDATED_TIME,
    NULLIF(TRIM(WORKT_CODETABLETAGS), 'NULL')             AS CODE_TABLE_TAGS,
    WORKT_CREATEDUSER_DR                                  AS CREATED_USER_DR,
    WORKT_UPDATEDUSER_DR                                  AS UPDATED_USER_DR,
    _AIRBYTE_EXTRACTED_AT                                 AS AIRBYTE_EXTRACTED_TS
FROM {{ ref('HIST_TRAKCARE_PAC_CONTWORKERTYPE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')