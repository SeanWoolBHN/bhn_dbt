SELECT
    NULLIF(TRIM(DEP_ROWID), 'NULL')                                       AS ROW_ID,
    NULLIF(TRIM(DEP_CODE), 'NULL')                                        AS CODE,
    NULLIF(TRIM(DEP_DESC), 'NULL')                                        AS DESCRIPTION,
    DEP_DATETO                                                            AS DATE_TO,
    DEP_PARREF                                                            AS PAR_REF,
    DEP_CHILDSUB                                                          AS CHILD_SUB,
    DEP_DATEFROM                                                          AS DATE_FROM,
    DEP_PRIORITY                                                          AS PRIORITY,
    DEP_CREATEDDATE                                                       AS CREATED_DATE,
    DEP_CREATEDTIME                                                       AS CREATED_TIME,
    DEP_UPDATEDDATE                                                       AS UPDATED_DATE,
    DEP_UPDATEDTIME                                                       AS UPDATED_TIME,
    NULLIF(TRIM(DEP_CODETABLETAGS), 'NULL')                               AS CODE_TABLE_TAGS,
    DEP_CREATEDUSER_DR                                                    AS CREATED_USER_DR,
    DEP_UPDATEDUSER_DR                                                    AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                                                 AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_CT_NFMI_CATEGDEPART') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')