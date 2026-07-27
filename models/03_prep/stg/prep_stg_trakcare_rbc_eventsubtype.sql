SELECT
    NULLIF(TRIM(SUB_ROWID), 'NULL')                                       AS ROW_ID,
    SUB_PARREF                                                            AS PAR_REF,
    SUB_CHILDSUB                                                          AS CHILD_SUB,
    SUB_CODE                                                              AS CODE,
    NULLIF(TRIM(SUB_DESC), 'NULL')                                        AS DESCRIPTION,
    SUB_DATEFROM                                                          AS DATE_FROM,
    NULLIF(TRIM(SUB_DATETO), 'NULL')                                      AS DATE_TO,
    NULLIF(TRIM(SUB_CODETABLETAGS), 'NULL')                               AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(SUB_CREATEDDATE), 'NULL'))                    AS CREATED_DATE,
    NULLIF(TRIM(SUB_CREATEDTIME), 'NULL')                                 AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(SUB_CREATEDUSER_DR), 'NULL'), 18, 6)        AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(SUB_UPDATEDDATE), 'NULL'))                    AS UPDATED_DATE,
    NULLIF(TRIM(SUB_UPDATEDTIME), 'NULL')                                 AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(SUB_UPDATEDUSER_DR), 'NULL'), 18, 6)        AS UPDATED_USER_DR

FROM {{ ref('HIST_TRAKCARE_RBC_EVENTSUBTYPE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')