SELECT
    LIVARR_ROWID                                                           AS ROW_ID,
    LIVARR_CODE                                                            AS CODE,
    NULLIF(TRIM(LIVARR_DESC), 'NULL')                                      AS DESCRIPTION,
    LIVARR_DATEFROM                                                        AS DATE_FROM,
    NULLIF(TRIM(LIVARR_DATETO), 'NULL')                                    AS DATE_TO,
    NULLIF(TRIM(LIVARR_NATIONCODE), 'NULL')                                AS NATION_CODE,
    NULLIF(TRIM(LIVARR_NATIONCODEDESC), 'NULL')                            AS NATION_CODE_DESC,
    NULLIF(TRIM(LIVARR_OWNER), 'NULL')                                     AS OWNER,
    NULLIF(TRIM(LIVARR_CODETABLETAGS), 'NULL')                             AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(LIVARR_CREATEDDATE), 'NULL'))                  AS CREATED_DATE,
    NULLIF(TRIM(LIVARR_CREATEDTIME), 'NULL')                               AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(LIVARR_CREATEDUSER_DR), 'NULL'), 18, 6)      AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(LIVARR_UPDATEDDATE), 'NULL'))                  AS UPDATED_DATE,
    NULLIF(TRIM(LIVARR_UPDATEDTIME), 'NULL')                               AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(LIVARR_UPDATEDUSER_DR), 'NULL'), 18, 6)      AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                                                  AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_LIVINGARRANGEMENT') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')