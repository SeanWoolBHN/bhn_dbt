SELECT
    APTR_ROWID                                                            AS ROW_ID,
    NULLIF(TRIM(APTR_CODE), 'NULL')                                       AS CODE,
    NULLIF(TRIM(APTR_DESC), 'NULL')                                       AS DESCRIPTION,
    APTR_DATEFROM                                                         AS DATE_FROM,
    NULLIF(TRIM(APTR_DATETO), 'NULL')                                     AS DATE_TO,
    NULLIF(TRIM(APTR_CONTACTMETHOD), 'NULL')                              AS CONTACT_METHOD,
    LOWER(NULLIF(TRIM(APTR_EMAIL), 'NULL'))                               AS EMAIL,
    NULLIF(TRIM(APTR_FAX), 'NULL')                                        AS FAX,
    NULLIF(TRIM(APTR_PHONE), 'NULL')                                      AS PHONE,
    NULLIF(TRIM(APTR_ADRESS), 'NULL')                                     AS ADDRESS_1,
    NULLIF(TRIM(APTR_OWNER), 'NULL')                                      AS OWNER,
    NULLIF(TRIM(APTR_CODETABLETAGS), 'NULL')                              AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(APTR_CREATEDDATE), 'NULL'))                   AS CREATED_DATE,
    NULLIF(TRIM(APTR_CREATEDTIME), 'NULL')                                AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(APTR_CREATEDUSER_DR), 'NULL'), 18, 6)       AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(APTR_UPDATEDDATE), 'NULL'))                   AS UPDATED_DATE,
    NULLIF(TRIM(APTR_UPDATEDTIME), 'NULL')                                AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(APTR_UPDATEDUSER_DR), 'NULL'), 18, 6)       AS UPDATED_USER_DR

FROM {{ ref('HIST_TRAKCARE_RBC_APPOINTTRANSPORT') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')