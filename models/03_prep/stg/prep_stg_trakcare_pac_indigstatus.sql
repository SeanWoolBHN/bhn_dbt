SELECT
    INDST_ROWID                                   AS ROW_ID,
    INDST_CODE                                    AS CODE,
    TRIM(INDST_DESC)                              AS DESC,
    INDST_DATEFROM                                AS DATE_FROM,
    TRIM(INDST_DATETO)                            AS DATE_TO,
    TRIM(INDST_NATIONALCODE)                      AS NATIONAL_CODE,
    TRIM(INDST_OWNER)                             AS OWNER,
    TRIM(INDST_CODETABLETAGS)                     AS CODE_TABLE_TAGS,
    TRIM(INDST_CREATEDDATE)                       AS CREATED_DATE,
    TRIM(INDST_CREATEDTIME)                       AS CREATED_TIME,
    TRIM(INDST_CREATEDUSER_DR)                    AS CREATED_USER_DR,
    TRIM(INDST_UPDATEDDATE)                       AS UPDATED_DATE,
    TRIM(INDST_UPDATEDTIME)                       AS UPDATED_TIME,
    TRIM(INDST_UPDATEDUSER_DR)                    AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_INDIGSTATUS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')