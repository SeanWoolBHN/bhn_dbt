SELECT
    CTSEX_ROWID                                   AS ROW_ID,
    TRIM(CTSEX_CODE)                              AS CODE,
    TRIM(CTSEX_DESC)                              AS DESC,
    CTSEX_GROUPERCODE                             AS GROUPER_CODE,
    CTSEX_DATEFROM                                AS DATE_FROM,
    TRIM(CTSEX_DATETO)                            AS DATE_TO,
    TRIM(CTSEX_GENDER)                            AS GENDER,
    TRIM(CTSEX_HL7CODE)                           AS HL7_CODE,
    TRIM(CTSEX_ICONNAME)                          AS ICON_NAME,
    TRIM(CTSEX_OWNER)                             AS OWNER,
    TRIM(CTSEX_CODETABLETAGS)                     AS CODE_TABLE_TAGS,
    CTSEX_CREATEDDATE                             AS CREATED_DATE,
    TRIM(CTSEX_CREATEDTIME)                       AS CREATED_TIME,
    TRIM(CTSEX_CREATEDUSER_DR)                    AS CREATED_USER_DR,
    CTSEX_UPDATEDDATE                             AS UPDATED_DATE,
    TRIM(CTSEX_UPDATEDTIME)                       AS UPDATED_TIME,
    TRIM(CTSEX_UPDATEDUSER_DR)                    AS UPDATED_USER_DR,
    TRIM(CTSEX_CODETRANSLATED)                    AS CODE_TRANSLATED,
    TRIM(CTSEX_DESCTRANSLATED)                    AS DESC_TRANSLATED,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_CT_SEX') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')