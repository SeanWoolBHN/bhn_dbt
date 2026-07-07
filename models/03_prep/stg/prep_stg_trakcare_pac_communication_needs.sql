SELECT
    COMMNEEDS_ROWID                                                        AS ROW_ID,
    COMMNEEDS_CODE                                                         AS CODE,
    NULLIF(TRIM(COMMNEEDS_DESC), 'NULL')                                   AS DESCRIPTION,
    COMMNEEDS_DATEFROM                                                     AS DATE_FROM,
    COMMNEEDS_DATETO                                                       AS DATE_TO,
    NULLIF(TRIM(COMMNEEDS_OWNER), 'NULL')                                  AS OWNER,
    NULLIF(TRIM(COMMNEEDS_CODETABLETAGS), 'NULL')                          AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(COMMNEEDS_CREATEDDATE), 'NULL'))               AS CREATED_DATE,
    NULLIF(TRIM(COMMNEEDS_CREATEDTIME), 'NULL')                            AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(COMMNEEDS_CREATEDUSER_DR), 'NULL'), 18, 6)   AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(COMMNEEDS_UPDATEDDATE), 'NULL'))               AS UPDATED_DATE,
    NULLIF(TRIM(COMMNEEDS_UPDATEDTIME), 'NULL')                            AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(COMMNEEDS_UPDATEDUSER_DR), 'NULL'), 18, 6)   AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                                                  AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_COMMUNICATIONNEEDS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')