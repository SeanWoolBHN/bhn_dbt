SELECT
    EMPLST_ROWID                                                           AS ROW_ID,
    NULLIF(TRIM(EMPLST_CODE), 'NULL')                                      AS CODE,
    NULLIF(TRIM(EMPLST_DESC), 'NULL')                                      AS DESCRIPTION,
    EMPLST_DATEFROM                                                        AS DATE_FROM,
    NULLIF(TRIM(EMPLST_DATETO), 'NULL')                                    AS DATE_TO,
    NULLIF(TRIM(EMPLST_NATIONCODE), 'NULL')                                AS NATION_CODE,
    NULLIF(TRIM(EMPLST_OWNER), 'NULL')                                     AS OWNER,
    NULLIF(TRIM(EMPLST_CODETABLETAGS), 'NULL')                             AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(EMPLST_CREATEDDATE), 'NULL'))                  AS CREATED_DATE,
    NULLIF(TRIM(EMPLST_CREATEDTIME), 'NULL')                               AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(EMPLST_CREATEDUSER_DR), 'NULL'), 18, 6)      AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(EMPLST_UPDATEDDATE), 'NULL'))                  AS UPDATED_DATE,
    NULLIF(TRIM(EMPLST_UPDATEDTIME), 'NULL')                               AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(EMPLST_UPDATEDUSER_DR), 'NULL'), 18, 6)      AS UPDATED_USER_DR,
    NULLIF(TRIM(EMPLST_CODETRANSLATED), 'NULL')                            AS CODE_TRANSLATED,
    NULLIF(TRIM(EMPLST_DESCTRANSLATED), 'NULL')                            AS DESC_TRANSLATED,

    _AIRBYTE_EXTRACTED_AT                                                  AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_EMPLOYMENTSTATUS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')