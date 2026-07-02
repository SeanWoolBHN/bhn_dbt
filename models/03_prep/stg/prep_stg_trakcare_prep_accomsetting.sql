SELECT
    ACCOMS_ROWID                                  AS ROWID,
    TRIM(ACCOMS_CODE)                             AS CODE,
    TRIM(ACCOMS_DESC)                             AS DESC,
    ACCOMS_DATEFROM                               AS DATE_FROM,
    TRIM(ACCOMS_DATETO)                           AS DATE_TO,
    TRIM(ACCOMS_OWNER)                            AS OWNER,
    TRIM(ACCOMS_CODETABLETAGS)                    AS CODE_TABLE_TAGS,
    TRIM(ACCOMS_CREATEDDATE)                      AS CREATED_DATE,
    TRIM(ACCOMS_CREATEDTIME)                      AS CREATED_TIME,
    TRIM(ACCOMS_CREATEDUSER_DR)                   AS CREATED_USER_DR,
    TRIM(ACCOMS_UPDATEDDATE)                      AS UPDATED_DATE,
    TRIM(ACCOMS_UPDATEDTIME)                      AS UPDATED_TIME,
    TRIM(ACCOMS_UPDATEDUSER_DR)                   AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_ACCOMSETTING') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')