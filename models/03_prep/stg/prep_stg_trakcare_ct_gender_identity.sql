SELECT
    GENID_ROWID                                   AS ROW_ID,
    GENID_CODE                                    AS CODE,
    TRIM(GENID_DESC)                              AS DESC,
    GENID_DATEFROM                                AS DATE_FROM,
    GENID_DATETO                                  AS DATE_TO,
    TRIM(GENID_OWNER)                             AS OWNER,
    TRIM(GENID_CODETABLETAGS)                     AS CODE_TABLE_TAGS,
    TRIM(GENID_CREATEDDATE)                       AS CREATED_DATE,
    TRIM(GENID_CREATEDTIME)                       AS CREATED_TIME,
    TRY_TO_NUMBER(TRIM(GENID_CREATEDUSER_DR),18,6) AS CREATED_USER_DR,
    TRIM(GENID_UPDATEDDATE)                       AS UPDATED_DATE,
    TRIM(GENID_UPDATEDTIME)                       AS UPDATED_TIME,
    TRY_TO_NUMBER(TRIM(GENID_UPDATEDUSER_DR),18,6) AS UPDATED_USER_DR,
    TRIM(GENID_GROUPCODE)                         AS GROUP_CODE,
    TRIM(GENID_HL7MAPPING)                        AS HL7_MAPPING,
    TRIM(GENID_GENDER)                            AS GENDER,

    _AIRBYTE_EXTRACTED_AT                         AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_CT_GENDERIDENTITY') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')