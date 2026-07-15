SELECT
    NULLIF(TRIM(SUB_ROWID), 'NULL')                                       AS ROW_ID,
    SUB_PARREF                                                            AS PAR_REF,
    SUB_CHILDSUB                                                          AS CHILD_SUB,
    NULLIF(TRIM(SUB_CODE), 'NULL')                                        AS CODE,
    NULLIF(TRIM(SUB_DESC), 'NULL')                                        AS DESCRIPTION,
    SUB_CODETABLETAGS                                                     AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(SUB_CREATEDDATE), 'NULL'))                    AS CREATED_DATE,
    NULLIF(TRIM(SUB_CREATEDTIME), 'NULL')                                 AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(SUB_CREATEDUSER_DR), 'NULL'), 18, 6)        AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(SUB_UPDATEDDATE), 'NULL'))                    AS UPDATED_DATE,
    NULLIF(TRIM(SUB_UPDATEDTIME), 'NULL')                                 AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(SUB_UPDATEDUSER_DR), 'NULL'), 18, 6)        AS UPDATED_USER_DR

FROM {{ ref('HIST_TRAKCARE_CT_GOVERNSUBCAT') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')