SELECT
    LIVARR_ROWID                                  AS ROW_ID,
    LIVARR_CODE                                   AS CODE,
    TRIM(LIVARR_DESC)                             AS DESC,
    LIVARR_DATEFROM                               AS DATE_FROM,
    TRIM(LIVARR_DATETO)                           AS DATE_TO,
    TRIM(LIVARR_NATIONCODE)                       AS NATION_CODE,
    TRIM(LIVARR_NATIONCODEDESC)                   AS NATION_CODE_DESC,
    TRIM(LIVARR_OWNER)                            AS OWNER,
    TRIM(LIVARR_CODETABLETAGS)                    AS CODE_TABLE_TAGS,
    TRIM(LIVARR_CREATEDDATE)                      AS CREATED_DATE,
    TRIM(LIVARR_CREATEDTIME)                      AS CREATED_TIME,
    TRIM(LIVARR_CREATEDUSER_DR)                   AS CREATED_USER_DR,
    TRIM(LIVARR_UPDATEDDATE)                      AS UPDATED_DATE,
    TRIM(LIVARR_UPDATEDTIME)                      AS UPDATED_TIME,
    TRIM(LIVARR_UPDATEDUSER_DR)                   AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_LIVINGARRANGEMENT') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')