SELECT
    EMPLST_ROWID                                  AS ROW_ID,
    TRIM(EMPLST_CODE)                             AS CODE,
    TRIM(EMPLST_DESC)                             AS DESC,
    EMPLST_DATEFROM                               AS DATE_FROM,
    TRIM(EMPLST_DATETO)                           AS DATE_TO,
    TRIM(EMPLST_NATIONCODE)                       AS NATION_CODE,
    TRIM(EMPLST_OWNER)                            AS OWNER,
    TRIM(EMPLST_CODETABLETAGS)                    AS CODE_TABLE_TAGS,
    TRIM(EMPLST_CREATEDDATE)                      AS CREATED_DATE,
    TRIM(EMPLST_CREATEDTIME)                      AS CREATED_TIME,
    TRIM(EMPLST_CREATEDUSER_DR)                   AS CREATED_USER_DR,
    TRIM(EMPLST_UPDATEDDATE)                      AS UPDATED_DATE,
    TRIM(EMPLST_UPDATEDTIME)                      AS UPDATED_TIME,
    TRIM(EMPLST_UPDATEDUSER_DR)                   AS UPDATED_USER_DR,
    TRIM(EMPLST_CODETRANSLATED)                   AS CODE_TRANSLATED,
    TRIM(EMPLST_DESCTRANSLATED)                   AS DESC_TRANSLATED,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_EMPLOYMENTSTATUS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')