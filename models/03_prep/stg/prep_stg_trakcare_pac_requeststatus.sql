SELECT
    REQST_ROWID                                                           AS ROW_ID,
    NULLIF(TRIM(REQST_CODE), 'NULL')                                      AS CODE,
    NULLIF(TRIM(REQST_DESC), 'NULL')                                      AS DESCRIPTION,
    REQST_DATEFROM                                                        AS DATE_FROM,
    NULLIF(TRIM(REQST_DATETO), 'NULL')                                    AS DATE_TO,
    NULLIF(TRIM(REQST_OWNER), 'NULL')                                     AS OWNER,
    NULLIF(TRIM(REQST_CODETABLETAGS), 'NULL')                             AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(REQST_CREATEDDATE), 'NULL'))                  AS CREATED_DATE,
    NULLIF(TRIM(REQST_CREATEDTIME), 'NULL')                               AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(REQST_CREATEDUSER_DR), 'NULL'), 18, 6)      AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(REQST_UPDATEDDATE), 'NULL'))                  AS UPDATED_DATE,
    NULLIF(TRIM(REQST_UPDATEDTIME), 'NULL')                               AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(REQST_UPDATEDUSER_DR), 'NULL'), 18, 6)      AS UPDATED_USER_DR,
    NULLIF(TRIM(REQST_CODETRANSLATED), 'NULL')                            AS CODE_TRANSLATED,
    NULLIF(TRIM(REQST_DESCTRANSLATED), 'NULL')                            AS DESC_TRANSLATED

FROM {{ ref('HIST_TRAKCARE_PAC_REQUESTSTATUS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')