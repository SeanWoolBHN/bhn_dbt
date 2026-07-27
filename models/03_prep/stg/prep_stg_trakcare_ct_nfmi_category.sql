SELECT
    NFMI_ROWID                                                            AS ROW_ID,
    NULLIF(TRIM(NFMI_CODE), 'NULL')                                       AS CODE,
    NULLIF(TRIM(NFMI_DESC), 'NULL')                                       AS DESCRIPTION,
    NULLIF(TRIM(NFMI_OWNER), 'NULL')                                      AS OWNER,
    NFMI_DATETO                                                           AS DATE_TO,
    NFMI_DATEFROM                                                         AS DATE_FROM,
    NFMI_CREATEDDATE                                                      AS CREATED_DATE,
    NFMI_CREATEDTIME                                                      AS CREATED_TIME,
    NFMI_LINKNFMI_DR                                                      AS LINK_NFMI_DR,
    NFMI_UPDATEDDATE                                                      AS UPDATED_DATE,
    NFMI_UPDATEDTIME                                                      AS UPDATED_TIME,
    NULLIF(TRIM(NFMI_INSBATCHONLY), 'NULL')                               AS INS_BATCH_ONLY,
    NULLIF(TRIM(NFMI_CODETABLETAGS), 'NULL')                              AS CODE_TABLE_TAGS,
    NFMI_CREATEDUSER_DR                                                   AS CREATED_USER_DR,
    NULLIF(TRIM(NFMI_GOVSUBCATEG_DR), 'NULL')                             AS GOV_SUB_CATEG_DR,
    NFMI_UPDATEDUSER_DR                                                   AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                                                 AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_CT_NFMI_CATEGORY') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')