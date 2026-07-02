SELECT
    CTNAT_ROWID                                   AS ROW_ID,
    TRIM(CTNAT_CODE)                              AS CODE,
    TRIM(CTNAT_DESC)                              AS DESC,
    TRIM(CTNAT_OWNER)                             AS OWNER,
    TRIM(CTNAT_CODETABLETAGS)                     AS CODE_TABLE_TAGS,
    TRIM(CTNAT_CREATEDDATE)                       AS CREATED_DATE,
    TRIM(CTNAT_CREATEDTIME)                       AS CREATED_TIME,
    TRIM(CTNAT_CREATEDUSER_DR)                    AS CREATED_USER_DR,
    TRIM(CTNAT_UPDATEDDATE)                       AS UPDATED_DATE,
    TRIM(CTNAT_UPDATEDTIME)                       AS UPDATED_TIME,
    TRIM(CTNAT_UPDATEDUSER_DR)                    AS UPDATED_USER_DR,
    TRIM(CTNAT_RESIDENT)                          AS RESIDENT,
    CTNAT_DATEFROM                                AS DATE_FROM,
    TRIM(CTNAT_DATETO)                            AS DATE_TO,
    TRIM(CTNAT_NATIONALCODE)                      AS NATIONAL_CODE,
    TRIM(CTNAT_ISO3166CODE)                       AS ISO3166_CODE,
    TRIM(CTNAT_ISO3166ALPHA2CODE)                 AS ISO3166_ALPHA2_CODE,
    TRIM(CTNAT_ISO3166ALPHA3CODE)                 AS ISO3166_ALPHA3_CODE,
    TRIM(CTNAT_NATIONALITYGROUP_DR)               AS NATIONALITY_GROUP_DR,
    TRIM(CTNAT_CODETRANSLATED)                    AS CODE_TRANSLATED,
    TRIM(CTNAT_DESCTRANSLATED)                    AS DESC_TRANSLATED,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_CT_NATION') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')