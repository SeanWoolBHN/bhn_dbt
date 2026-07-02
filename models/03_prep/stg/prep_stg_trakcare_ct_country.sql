SELECT
    CTCOU_ROWID                                   AS ROW_ID,
    TRIM(CTCOU_CODE)                              AS CODE,
    TRIM(CTCOU_DESC)                              AS DESC,
    CTCOU_ACTIVE                                  AS ACTIVE,
    CTCOU_DATEACTIVEFROM                          AS DATE_ACTIVE_FROM,
    TRIM(CTCOU_DATEACTIVETO)                      AS DATE_ACTIVE_TO,
    TRIM(CTCOU_OWNER)                             AS OWNER,
    TRIM(CTCOU_CODETABLETAGS)                     AS CODE_TABLE_TAGS,
    TRIM(CTCOU_CREATEDDATE)                       AS CREATED_DATE,
    TRIM(CTCOU_CREATEDTIME)                       AS CREATED_TIME,
    TRIM(CTCOU_CREATEDUSER_DR)                    AS CREATED_USER_DR,
    TRIM(CTCOU_UPDATEDDATE)                       AS UPDATED_DATE,
    TRIM(CTCOU_UPDATEDTIME)                       AS UPDATED_TIME,
    TRIM(CTCOU_UPDATEDUSER_DR)                    AS UPDATED_USER_DR,
    TRIM(CTCOU_NATIONALCODE)                      AS NATIONAL_CODE,
    TRIM(CTCOU_ISO3166CODE)                       AS ISO3166_CODE,
    TRIM(CTCOU_ISO3166ALPHA2CODE)                 AS ISO3166_ALPHA2_CODE,
    TRIM(CTCOU_ISO3166ALPHA3CODE)                 AS ISO3166_ALPHA3_CODE,
    TRIM(CTCOU_CODETRANSLATED)                    AS CODE_TRANSLATED,
    TRIM(CTCOU_DESCTRANSLATED)                    AS DESC_TRANSLATED,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_CT_COUNTRY') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')