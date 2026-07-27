SELECT
    EVT_ROWID                                                             AS ROW_ID,
    NULLIF(TRIM(EVT_CODE), 'NULL')                                        AS CODE,
    NULLIF(TRIM(EVT_DESC), 'NULL')                                        AS DESCRIPTION,
    EVT_DATEFROM                                                          AS DATE_FROM,
    NULLIF(TRIM(EVT_DATETO), 'NULL')                                      AS DATE_TO,
    NULLIF(TRIM(EVT_OWNER), 'NULL')                                       AS OWNER,
    NULLIF(TRIM(EVT_CODETABLETAGS), 'NULL')                               AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(EVT_CREATEDDATE), 'NULL'))                    AS CREATED_DATE,
    NULLIF(TRIM(EVT_CREATEDTIME), 'NULL')                                 AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(EVT_CREATEDUSER_DR), 'NULL'), 18, 6)        AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(EVT_UPDATEDDATE), 'NULL'))                    AS UPDATED_DATE,
    NULLIF(TRIM(EVT_UPDATEDTIME), 'NULL')                                 AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(EVT_UPDATEDUSER_DR), 'NULL'), 18, 6)        AS UPDATED_USER_DR

FROM {{ ref('HIST_TRAKCARE_RBC_EVENTTYPE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')