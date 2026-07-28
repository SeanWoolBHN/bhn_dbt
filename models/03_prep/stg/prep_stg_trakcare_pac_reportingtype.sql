SELECT
    REPTYPE_ROWID                                                         AS ROW_ID,
    NULLIF(TRIM(REPTYPE_CODE), 'NULL')                                    AS CODE,
    NULLIF(TRIM(REPTYPE_DESC), 'NULL')                                    AS DESCRIPTION,
    TRY_TO_DATE(NULLIF(TRIM(REPTYPE_DATEFROM), 'NULL'))                   AS DATE_FROM,
    TRY_TO_DATE(NULLIF(TRIM(REPTYPE_DATETO), 'NULL'))                     AS DATE_TO,
    NULLIF(TRIM(REPTYPE_NATIONALCODE), 'NULL')                            AS NATIONAL_CODE,
    NULLIF(TRIM(REPTYPE_NATIONCODETABLEMNGTINSTRUCTIONS), 'NULL')         AS NAT_CODE_TABLE_MNGT_INSTRUCTIONS,
    NULLIF(TRIM(REPTYPE_OWNER), 'NULL')                                   AS OWNER,
    NULLIF(TRIM(REPTYPE_CODETABLETAGS), 'NULL')                           AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(REPTYPE_CREATEDDATE), 'NULL'))                AS CREATED_DATE,
    REPTYPE_CREATEDTIME                                                   AS CREATED_TIME,
    REPTYPE_CREATEDUSER_DR                                                AS CREATED_USER_DR,
    REPTYPE_UPDATEDDATE                                                   AS UPDATED_DATE,
    REPTYPE_UPDATEDTIME                                                   AS UPDATED_TIME,
    REPTYPE_UPDATEDUSER_DR                                                AS UPDATED_USER_DR

FROM {{ ref('HIST_TRAKCARE_PAC_REPORTINGTYPE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')