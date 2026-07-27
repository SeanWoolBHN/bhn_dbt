SELECT
    PENSTYPE_ROWID                                                        AS ROW_ID,
    PENSTYPE_CODE                                                         AS CODE,
    NULLIF(TRIM(PENSTYPE_DESC), 'NULL')                                   AS DESCRIPTION,
    PENSTYPE_DATEFROM                                                     AS DATE_FROM,
    NULLIF(TRIM(PENSTYPE_DATETO), 'NULL')                                 AS DATE_TO,
    NULLIF(TRIM(PENSTYPE_OWNER), 'NULL')                                  AS OWNER,
    NULLIF(TRIM(PENSTYPE_CODETABLETAGS), 'NULL')                          AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(PENSTYPE_CREATEDDATE), 'NULL'))               AS CREATED_DATE,
    NULLIF(TRIM(PENSTYPE_CREATEDTIME), 'NULL')                            AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(PENSTYPE_CREATEDUSER_DR), 'NULL'), 18, 6)   AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(PENSTYPE_UPDATEDDATE), 'NULL'))               AS UPDATED_DATE,
    NULLIF(TRIM(PENSTYPE_UPDATEDTIME), 'NULL')                            AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(PENSTYPE_UPDATEDUSER_DR), 'NULL'), 18, 6)   AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                                                 AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_PENSIONTYPE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')