SELECT
    CONTSERREC2_ROWID                                     AS ROW_ID,
    NULLIF(TRIM(CONTSERREC2_CODE), 'NULL')                AS CODE,
    NULLIF(TRIM(CONTSERREC2_DESC), 'NULL')                AS DESCRIPTION,
    NULLIF(TRIM(CONTSERREC2_OWNER), 'NULL')               AS OWNER,
    CONTSERREC2_DATETO                                    AS DATE_TO,
    CONTSERREC2_DATEFROM                                  AS DATE_FROM,
    CONTSERREC2_CREATEDDATE                               AS CREATED_DATE,
    CONTSERREC2_CREATEDTIME                               AS CREATED_TIME,
    CONTSERREC2_UPDATEDDATE                               AS UPDATED_DATE,
    CONTSERREC2_UPDATEDTIME                               AS UPDATED_TIME,
    NULLIF(TRIM(CONTSERREC2_CODETABLETAGS), 'NULL')       AS CODE_TABLE_TAGS,
    CONTSERREC2_CREATEDUSER_DR                            AS CREATED_USER_DR,
    CONTSERREC2_UPDATEDUSER_DR                            AS UPDATED_USER_DR,
    _AIRBYTE_EXTRACTED_AT                                 AS AIRBYTE_EXTRACTED_TS
FROM {{ ref('HIST_TRAKCARE_PAC_CONTSERVICEREC2') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')