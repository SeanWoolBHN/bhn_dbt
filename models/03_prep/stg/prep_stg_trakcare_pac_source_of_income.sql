SELECT
    SRCINC_ROWID                                  AS ROW_ID,
    SRCINC_CODE                                   AS CODE,
    TRIM(SRCINC_DESC)                             AS DESC,
    SRCINC_DATEFROM                               AS DATE_FROM,
    TRIM(SRCINC_DATETO)                           AS DATE_TO,
    TRIM(SRCINC_NATIONCODE)                       AS NATION_CODE,
    TRIM(SRCINC_NATIONCODEDESC)                   AS NATION_CODE_DESC,
    TRIM(SRCINC_OWNER)                            AS OWNER,
    TRIM(SRCINC_CODETABLETAGS)                    AS CODE_TABLE_TAGS,
    TRIM(SRCINC_CREATEDDATE)                      AS CREATED_DATE,
    TRIM(SRCINC_CREATEDTIME)                      AS CREATED_TIME,
    TRIM(SRCINC_CREATEDUSER_DR)                   AS CREATED_USER_DR,
    TRIM(SRCINC_UPDATEDDATE)                      AS UPDATED_DATE,
    TRIM(SRCINC_UPDATEDTIME)                      AS UPDATED_TIME,
    TRIM(SRCINC_UPDATEDUSER_DR)                   AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_SOURCEOFINCOME') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')