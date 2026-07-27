SELECT
    OSTAT_ROWID                                                           AS ROW_ID,
    NULLIF(TRIM(OSTAT_CODE), 'NULL')                                      AS CODE,
    NULLIF(TRIM(OSTAT_DESC), 'NULL')                                      AS DESCRIPTION,
    NULLIF(TRIM(OSTAT_COLOR), 'NULL')                                     AS COLOR,
    NULLIF(TRIM(OSTAT_ACTIVATE), 'NULL')                                  AS ACTIVATE,
    OSTAT_CREATEDDATE                                                     AS CREATED_DATE,
    OSTAT_CREATEDTIME                                                     AS CREATED_TIME,
    OSTAT_UPDATEDDATE                                                     AS UPDATED_DATE,
    OSTAT_UPDATEDTIME                                                     AS UPDATED_TIME,
    OSTAT_CREATEDUSER_DR                                                  AS CREATED_USER_DR,
    OSTAT_UPDATEDUSER_DR                                                  AS UPDATED_USER_DR,
    _AIRBYTE_EXTRACTED_AT                                                 AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_OEC_ORDERSTATUS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')